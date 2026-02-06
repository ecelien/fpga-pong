 #include "platform.h"
 #include "xparameters.h"
 #include "xil_printf.h"
 #include "xil_types.h"
#include <stdint.h>
#include <unistd.h>

// UNCOMMENT THE ABOVE HEADERS WHEN YOURE ACTUALLY BUILDING IT

// paddle constants
#define PADDLE_HEIGHT 100
#define PADDLE_WIDTH 10
#define PADDLE_MOVE 5

// ball constants
#define BALL_WIDTH 5
#define BALL_MOVE_X 5
#define BALL_MOVE_Y 2

#define BALL_START_X 308
#define BALL_START_Y 228

// frame constants
#define X_BOUND 639
#define Y_BOUND 399
#define GAMESPEED 33333 //in microseconds, so for 30fps, 33333 us

// memory locations
#define LPADDLE_UP_INADDR (uint32_t*) XPAR_AXI_GPIO_0_BASEADDR
#define LPADDLE_DN_INADDR (uint32_t*) XPAR_AXI_GPIO_0_BASEADDR
#define RPADDLE_UP_INADDR (uint32_t*) XPAR_AXI_GPIO_0_BASEADDR
#define RPADDLE_DN_INADDR (uint32_t*) XPAR_AXI_GPIO_0_BASEADDR
#define BALL_X_OUTADDR (uint32_t*)XPAR_IMAGE_GEN_2_AXI_0_BASEADDR
#define BALL_Y_OUTADDR (uint32_t*)XPAR_IMAGE_GEN_2_AXI_0_BASEADDR + 1
#define LPADDLE_Y_OUTADDR (uint32_t*)XPAR_IMAGE_GEN_2_AXI_0_BASEADDR + 2
#define RPADDLE_Y_OUTADDR (uint32_t*)XPAR_IMAGE_GEN_2_AXI_0_BASEADDR + 3
#define RSCORE_OUTADDR (uint32_t*) XPAR_IMAGE_GEN_2_AXI_0_BASEADDR + 4
#define LSCORE_OUTADDR (uint32_t*) XPAR_IMAGE_GEN_2_AXI_0_BASEADDR + 5
// Enumerations
// State Machine
typedef enum {
    RESET,
	SCORE,
    GAME
} state_t;

// This typedef is for storing paddle directions
typedef enum {
	NO_DIR,
	UP,
	DOWN
} direction_t;

// This typedef is for referring to which player
typedef enum {
	NO_PLAYER,
	LEFT_PLAYER,
	RIGHT_PLAYER
} player_t;

// Structs
typedef struct U32Input {
	// The stored value read at the beginning of each loop
	uint32_t value;

	// The AXI-Read Location
	uint32_t * in_ptr;
} U32Input;

typedef struct U32Output {
	// The stored value to be wrtitten at the end of each loop
    uint32_t value;

	// The AXI-Write Location
	uint32_t * out_ptr;
} U32Output;

typedef struct Ball {
	U32Output x;
	U32Output y;
	int8_t velocity_x;
	int8_t velocity_y;
} Ball;

typedef struct Paddle {
	U32Output y;
	U32Input up;
	U32Input down;

	// The direction enum is an easy way to access the direction.
	// At the beginning of each loop, it is set according to the input combination
	// Can be UP, DOWN, or NO_DIR
	direction_t direction;
} Paddle;

void SetOutput(U32Output *output);
void GetInput(U32Input *input);

void ResetScores(U32Output *lscore, U32Output *rscore);
void ResetPaddles(Paddle *lpaddle, Paddle *rpaddle);
void ResetBall(Ball *ball);

void MovePaddle(Paddle *paddle);
player_t MoveBall(Ball *ball, Paddle lpaddle, Paddle rpaddle);

void UpdateInputs(Paddle *lpaddle, Paddle *rpaddle);
void UpdateOutputs(Ball *ball,Paddle *lpaddle, Paddle *rpaddle, U32Output *lscore, U32Output *rscore);


int main()
{
    init_platform();

	//initialize objects with their AXI addresses
	U32Output lscore = {
		.out_ptr = LSCORE_OUTADDR
	};
	U32Output rscore = {
		.out_ptr = RSCORE_OUTADDR
	};
	Ball ball = {
		.x.out_ptr = BALL_X_OUTADDR,
		.y.out_ptr = BALL_Y_OUTADDR
	};
	Paddle lpaddle = {
		.up.in_ptr = LPADDLE_UP_INADDR,
		.down.in_ptr = LPADDLE_DN_INADDR,
		.y.out_ptr = LPADDLE_Y_OUTADDR
	};
	Paddle rpaddle = {
		.up.in_ptr = RPADDLE_UP_INADDR,
		.down.in_ptr = RPADDLE_DN_INADDR,
		.y.out_ptr = RPADDLE_Y_OUTADDR
	};

	// set the first state to be the reset state
	state_t state = RESET;

	while(1) {
		// Here, every AXI input value is read and stored back into the object
		UpdateInputs(&lpaddle,&rpaddle);

		// If needed, set state according to reset value here
		switch (state) {
		case RESET:
			if (lpaddle.direction != NO_DIR || rpaddle.direction != NO_DIR) {
				state = GAME;
			}
			ResetScores(&lscore,&rscore);
			ResetBall(&ball);
			ResetPaddles(&lpaddle, &rpaddle);
			break;

		case SCORE:
			if (lpaddle.direction != NO_DIR || rpaddle.direction != NO_DIR) {
				state = GAME;
			}
			ResetBall(&ball);
			ResetPaddles(&lpaddle, &rpaddle);
			break;

		case GAME:

			MovePaddle(&lpaddle);
			MovePaddle(&rpaddle);

			switch (MoveBall(&ball, lpaddle, rpaddle)) {
			case LEFT_PLAYER:
				lscore.value++;
				// check if max score reached
				if (lscore.value > 7) {
					state = RESET;
					break;
				} else {
					state = SCORE;
					break;
				}
				break;
			case RIGHT_PLAYER:
				rscore.value++;
				if (rscore.value > 8) {
					state = RESET;
					break;
				} else {
					state = SCORE;
					break;
				}
				break;
			default:
				break;
			}
			break;
		}
		//xil_printf("state %d\n\r",state);
		UpdateOutputs(&ball,&lpaddle,&rpaddle,&lscore,&rscore);

		// wait
		usleep(GAMESPEED);
	}

    cleanup_platform();
    return 0;
}

// Returns the player who scored, LEFT_PLAYER, RIGHT_PLAYER, or NO_PLAYER
// And moves the ball according to its position and the paddle positions
player_t MoveBall(Ball *ball, Paddle lpaddle, Paddle rpaddle){
	player_t scoring_player = NO_PLAYER;
		// x axis
		// first check if there are any collisions
		// moving right
		if ((ball->velocity_x == 1) && (ball->x.value + BALL_MOVE_X + BALL_WIDTH >= X_BOUND - PADDLE_WIDTH)) {

			// if there is collision, check if with paddle or with score zone
			// collision with paddle
			// first check for ball moving up
			if ((ball->velocity_y == 0) &&
				(ball->y.value - BALL_MOVE_Y + BALL_WIDTH >= rpaddle.y.value) &&
				(ball->y.value - BALL_MOVE_Y <= rpaddle.y.value + PADDLE_HEIGHT)) { // in paddle

				// reflect x velocity, position stays the same
				ball->velocity_x = 0;

			} else if ((ball->velocity_y == 0) &&
					  ((ball->y.value - BALL_MOVE_X + BALL_WIDTH < rpaddle.y.value) ||
					  ( ball->y.value - BALL_MOVE_Y > rpaddle.y.value + PADDLE_HEIGHT)) ){ // in score zone

				// update score
				scoring_player = LEFT_PLAYER;

			// next check for ball moving down
			} else if ((ball->velocity_y == 1) && (ball->y.value + BALL_MOVE_Y + BALL_WIDTH >= rpaddle.y.value)
									&& (ball->y.value + BALL_MOVE_Y <= rpaddle.y.value + PADDLE_HEIGHT)) { // in paddle

				// reflect x velocity, position stays the same
				ball->velocity_x = 0;

			} else { // in score zone
				// update score
				scoring_player = LEFT_PLAYER;
			}

			//if there are no collisions, just move x position forward
		} else if (ball->velocity_x == 1) {
			ball->x.value += BALL_MOVE_X;
		}

		// now check for ball moving left
		if ((ball->velocity_x == 0) && (ball->x.value - BALL_MOVE_X <= PADDLE_WIDTH)) {
			// collision with paddle
			// first check for ball moving up
			if ((ball->velocity_y == 0) && (ball->y.value - BALL_MOVE_Y + BALL_WIDTH >= lpaddle.y.value)
									&& (ball->y.value - BALL_MOVE_Y <= lpaddle.y.value + PADDLE_HEIGHT)) { // in paddle

				// reflect x velocity, position stays the same
				ball->velocity_x = 1;

			} else if ((ball->velocity_y == 0) && ((ball->y.value - BALL_MOVE_X + BALL_WIDTH < lpaddle.y.value)
											|| ( ball->y.value - BALL_MOVE_Y > lpaddle.y.value + PADDLE_HEIGHT)) ){ // in score zone
				scoring_player = RIGHT_PLAYER;

			// next check for ball moving down
			} else if ((ball->velocity_y == 1) && (ball->y.value + BALL_MOVE_Y + BALL_WIDTH >= lpaddle.y.value)
									&& (ball->y.value + BALL_MOVE_Y <= lpaddle.y.value + PADDLE_HEIGHT)) { // in paddle

				// reflect x velocity, position stays the same
				ball->velocity_x = 1;

			} else { // in score zone
				// update score
				scoring_player = RIGHT_PLAYER;
			}
			//if there are no collisions, just move x position forward

		} else if (ball->velocity_x == 0) {
			ball->x.value -= BALL_MOVE_X;
		}

		// y-axis
		// checking for collision with top wall
		// actually checking if it's below bottom wall because position variable is unsigned
		if ((ball->velocity_y == 0) && (ball->y.value - BALL_MOVE_Y > Y_BOUND + 50)) {

			// setting y position and reflecting velocity
			ball->y.value = 5;
			ball->velocity_y = 1;

		// checking for collision w bottom wall
		} else if ((ball->velocity_y == 1) && (ball->y.value + BALL_MOVE_Y + BALL_WIDTH >= Y_BOUND)) {
			// setting y position and reflecting velocity
			ball->y.value = Y_BOUND - BALL_WIDTH;
			ball->velocity_y = 0;
		} else if (ball->velocity_y == 0) {
			ball->y.value -= BALL_MOVE_Y;
		} else {
			ball->y.value += BALL_MOVE_Y;
		}

		return scoring_player;
}

// Moves the paddle according to its inputs
void MovePaddle(Paddle *paddle){
	//xil_printf("paddle direction %d\n\r",paddle->direction);
	//xil_printf("paddle y %d\n\r",paddle->y.value);
	switch (paddle->direction)
	{
	case UP:
		// check if moving would put it out of bounds
		if (paddle->y.value >= PADDLE_MOVE) { // if not, move up
			paddle->y.value -= PADDLE_MOVE;
		} else { // if out of bounds, move it up to the border
			paddle->y.value = 0;
		}
		break;
	case DOWN:
		// check if moving would put it out of bounds
		if (paddle->y.value + PADDLE_HEIGHT <= Y_BOUND - PADDLE_MOVE) {
			paddle->y.value += PADDLE_MOVE;
		} else { // if out of bounds, move it down to the border
			paddle->y.value = Y_BOUND - PADDLE_HEIGHT;
		}
		break;
	default:
		break;
	}
	//xil_printf("paddle y %d\n\r",paddle->y.value);
}



// RESET FUNCTIONS

void ResetBall(Ball *ball) {
	ball->x.value = BALL_START_X;
	ball->y.value = BALL_START_Y;
	ball->velocity_x = 1;
	ball->velocity_y = 1;
}

void ResetPaddles(Paddle *lpaddle, Paddle *rpaddle) {
	lpaddle->y.value = Y_BOUND/2 - PADDLE_HEIGHT/2;
	rpaddle->y.value = Y_BOUND/2 - PADDLE_HEIGHT/2;
}

void ResetScores(U32Output *lscore, U32Output *rscore) {
	lscore->value = 0;
	rscore->value = 0;
}

// I/O HANDELING FUNCTIONS

// Just updates the value with the value in its AXI location
void GetInput(U32Input *input) {
	input->value = *(input->in_ptr);
}

// Just writes the set value to its AXI location
void SetOutput(U32Output *output) {
	//xil_printf("write %x\n\r",output->value);
	*(output->out_ptr) = output->value;
	//xil_printf("read %x\n\r",output->out_ptr);
}

// Performs the AXI input reads for both paddles and sets the direction enum accordingly
void UpdateInputs(Paddle *lpaddle, Paddle *rpaddle) {
    GetInput(&lpaddle->up);
    uint32_t buttons = lpaddle->up.value;

    //xil_printf("buttons %d\n\r", buttons);

    uint32_t is_up = (buttons & 1);
    uint32_t is_dn = (buttons & 2)>>1;
//    xil_printf("lup %d\n\r",is_up);
//    xil_printf("ldn %d\n\r",is_dn);

    lpaddle->direction = ((is_up ^ is_dn) ? (is_up ? UP : DOWN): NO_DIR);
//    xil_printf("ldir %d\n\r",lpaddle->direction);

    is_up = (buttons & 4)>>2;
    is_dn = (buttons & 8)>>3;
//    xil_printf("rup %d\n\r",is_up);
//    xil_printf("rdn %d\n\r",is_dn);

    rpaddle->direction = ((is_up ^ is_dn) ? (is_up ? UP : DOWN): NO_DIR);
//    xil_printf("rdir %d\n\r",rpaddle->direction);
}

// Writes all of the outputs to their AXI locations
void UpdateOutputs(Ball *ball,Paddle *lpaddle, Paddle *rpaddle, U32Output *lscore, U32Output *rscore) {
	SetOutput(&ball->x);
	SetOutput(&ball->y);
	SetOutput(&lpaddle->y);
	SetOutput(&rpaddle->y);
	SetOutput(lscore);
	SetOutput(rscore);
}
