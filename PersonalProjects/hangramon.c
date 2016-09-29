////In order of appearance:

//searching functions
void handle_side(int side);
int find_h(int side); //returns cm to hanger

//utilities
int over_black(int port);
void drivecm(int cm, int speed);
void line_follow();
void drive_until_black_parallel();
double to_degrees(double radians);
void turn_until_black();
void turn_angle(int angle, int speed);
int turn_to(int x, int y);
void turn_left();
void turn_right();
void servo_to(int port, int position);
void close_claw_right();
void close_claw_left();
void slow_open();
void lift_arm();
void lift_to_top();

//blobbing functions
void get_pos_array(int lowerLim);
void init_blobfield();
void blob_search(int i, int j, int last_depth);
void get_blob();
int get_blob_area();
void legit_init();
void print_blobfield();
int get_blob_center();
int get_blob_width();
int get_blob_height();

//gamelogic functions
void setup();
void hang_main();
void multi_turn_grab(int num);
void move_opposite();
void move_same();

//ports
#define PIVOT 2 //arm pivot servo (raises arm)
#define LIFTER 3 //lifts claw
#define CLAW 3 //opens and closes claw
#define RIGHT_REFLECT 0
#define LEFT_REFLECT 1
#define TOP_TOUCH 15

//Misc Defines
#define FALSE 0
#define TRUE 1
#define LEFT 1337
#define RIGHT 9001
#define PI 3.14159

#define SEARCH_WINDOW_HEIGHT 200
#define SEARCH_WINDOW_WIDTH 310

//Misc Constants
const int PIVOT_MIDDLE = 1600; //half way up
const int PIVOT_3Q = 1200; //three-quarters of the way up
const int PIVOT_UP = 680; //all the way UP position
const int CLAW_OPEN = 600;
const int CLAW_CLOSE = 1750;
const double easter_bunny_pass_2 = 65.0;

//x and z coords of closest point
int closest_z = 0;
int closest_x = 0;

//global left and right for blob
int gleft;
int gright;

//row col position fo closest point
int closest_ypos = 0;
int closest_xpos = 0;

//blobbing arrays
int depths[310][240];
int blob_field[310][240];
int legit_level;

//global variable for time when round starts
double start_time;

#define open_claw() servo_to(CLAW, CLAW_OPEN)
#define close_claw() servo_to(CLAW, CLAW_CLOSE)

#include <math.h>

int main(){
	printf("Believe in yourself; you can do anything\n");
	printf("except construct a set of axioms that is both complete and consistent and the other things that you can't do.\n");
	printf("You look nice this evening.\n"); // robotic motivation
	
	printf("Hangrador armor digivolve TO....... HANGRAMON: THE ROBOT OF COURAGE!!!\n");

	setup();
	hang_main();
	handle_side(RIGHT);
	turn_angle(7, -100); //turn back to middle before next search
	handle_side(LEFT);
	depth_close(); 
	return 0;
	
}
int find_h(int side){//side is LEFT or RIGHT, return -1 on fail, cm on success
	int row, col;
	int startRow, startCol;
	for(col = 0; col < SEARCH_WINDOW_WIDTH; col++){
		int found = FALSE;
		for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
			if(blob_field[col][row] && row < 100){ // found top left 1, never reset col after this
				startRow = row; // bounds top left of blob
				startCol = col;
				found = TRUE;
				break;
			}
		}
		if(found){
			break;
		}
	}

	int leftRack, rightRack;
	int endCol, endRow;
	printf("col: %d\n", col);
	for(; col < SEARCH_WINDOW_WIDTH; col++){
		int ones = 0;
		for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
			if(blob_field[col][row]){
				ones++;
			}
		}
		printf("ones: %d\n", ones);
		if(ones > SEARCH_WINDOW_HEIGHT * .50){ // found left pole, a col that has at least .55 the height of the window (hanger rack normally fills whole window)
			printf("left pole\n");
			for(; col < SEARCH_WINDOW_WIDTH; col++){
				ones = 0;
				for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
					if(blob_field[col][row]){
						ones++;
					}
				}
				if(ones < (SEARCH_WINDOW_HEIGHT-startRow)*.50){ // found left edge of rack, col which has significantly less height
					printf("left rack\n");
					leftRack = col;
					printf("ones: %d\n", ones);
					printf("left Rack: %d\n", leftRack);
					for(; col < SEARCH_WINDOW_WIDTH; col++){
						ones = 0;
						for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
							if(blob_field[col][row]){
								ones++;
							}
						}
						if(!(ones < (SEARCH_WINDOW_HEIGHT-startRow)*.50)){ // found right edge of rack, col which has significantly more height
							printf("right rack\n");
							rightRack = col;
							printf("ones: %d\n", ones);
							printf("right Rack: %d\n", rightRack);
							for(; col < SEARCH_WINDOW_WIDTH; col++){
								ones = 0;
								for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
									if(blob_field[col][row]){
										ones++;
									}
								}
								if(ones > SEARCH_WINDOW_HEIGHT*.50){ // found middle of right pole, still most of window
									printf("right pole\n");
									printf("ones: %d\n", ones);
									for(; col < SEARCH_WINDOW_WIDTH; col++){
										ones = 0;
										for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
											if(blob_field[col][row]){
												ones++;
											}
										}
										if(!(ones > SEARCH_WINDOW_HEIGHT*.50)){ // found outside of right pole, last col which is most of window, & succeeded with task
											printf("succeeded\n");
											endCol = col;//these two currently aren't used, but might be useful in future. Bounds bottom right of blob
											endRow = row;
											int h = endRow - startRow;
											int cm, x, y;
											if(side == RIGHT){ // if you are going for right, get the right edge coordinates
												printf("going for right\n");
												printf("Target point : Col: %d Row: %d\n", rightRack-3, SEARCH_WINDOW_HEIGHT-(get_blob_height()/2));
												if(!blob_field[rightRack-3][SEARCH_WINDOW_HEIGHT-(get_blob_height()/2)]){ //if point not in blob picked, move down
													printf("NOT IN BLOB\n");
													for(row = SEARCH_WINDOW_HEIGHT-(get_blob_height()/2); row < SEARCH_WINDOW_HEIGHT; row++){
														if(blob_field[rightRack-3][row]){
															printf("New Target point : Col: %d Row: %d\n", rightRack-3, row);
															// -3 to deal with lip of 3 way connector taking up space
															point3 p = get_depth_world_point(row+5, rightRack-3); 
															x = p.x+150;
															y = p.z-120;
															break;
														}
													}
													for(row = SEARCH_WINDOW_HEIGHT-(get_blob_height()/2); row > 0; row--){
														if(blob_field[rightRack-3][row]){
															printf("New Target point : Col: %d Row: %d\n", rightRack-3, row);
															// -3 to deal with lip of 3 way connector taking up space
															point3 p = get_depth_world_point(row-5, rightRack-3); 
															x = p.x+150;
															y = p.z-120;
															break;
														}
													}
													
												}
												else{
												// -3 to deal with lip of 3 way connector taking up space
												point3 p = get_depth_world_point(SEARCH_WINDOW_HEIGHT-(get_blob_height()/2), rightRack-3); 
												x = p.x+150;
												y = p.z-120;
												}
											}
											else if(side == LEFT){
												printf("going for left\n");
												printf("Target point : Col: %d Row: %d\n", leftRack+10, SEARCH_WINDOW_HEIGHT-(get_blob_height()/2));
												if(!blob_field[leftRack+10][SEARCH_WINDOW_HEIGHT-(get_blob_height()/2)]){ //if point not in blob picked, move down
													printf("NOT IN BLOB\n");
													for(row = SEARCH_WINDOW_HEIGHT-(get_blob_height()/2); row < SEARCH_WINDOW_HEIGHT; row++){
														if(blob_field[leftRack+10][row]){
															printf("New Target point : Col: %d Row: %d\n", leftRack+10, row);
															// +10 to deal with lip of 3 way connector taking up space
															point3 p = get_depth_world_point(row+5, leftRack+10); 
															x = p.x+150;
															y = p.z-120;
															break;
														}
													}
													for(row = SEARCH_WINDOW_HEIGHT-(get_blob_height()/2); row > 0; row--){
														if(blob_field[leftRack+10][row]){
															printf("New Target point : Col: %d Row: %d\n", leftRack+10, row);
															// +10 to deal with lip of 3 way connector taking up space
															point3 p = get_depth_world_point(row-5, leftRack+10); 
															x = p.x+150;
															y = p.z-120;
															break;
														}
													}
												}
												else{
												// +10 to deal with lip of 3 way connector taking up space
												point3 p = get_depth_world_point(SEARCH_WINDOW_HEIGHT-(get_blob_height()/2), leftRack+10); 
													
												x = p.x+150;
												y = p.z-120;
												}
											}
											else{ //bad argument!
												printf("Aaah! find_h() took a bad argument :(\n");
												return -1;
											}

											return turn_to(x, y);
										}
									}	
								}
							}
							// failed on right pole, slot for error correction
							drivecm(6, 100);
							if(get_create_lbump() || get_create_lbump()){
								turn_angle(5, 100);
								drivecm(60, -100);
							}
							printf("failed on right pole\n");
							return -1;	
						}
					}	
				}
			}
		}	
	}
	// failed on left pole, slot for error correction
	drivecm(6, 100);
	if(get_create_lbump() || get_create_lbump()){
		turn_angle(5, 100);
		drivecm(60, -100);
	}
	printf("failed on left pole\n");
	return -1;	
}

void handle_side(int side){// LEFT or RIGHT
	lift_to_top();
	get_blob(); // get first blob
	int cm, failcount = 0;
	
	do{
		failcount = 0;
		init_blobfield();
		while(get_blob_area()<800){  // if the blob is too small, it is not the whole rack
			
			init_blobfield();
			get_pos_array(depths[closest_xpos][closest_ypos]+40); // reset the search for the closest point, but push the closest point 5 cm back (prevents hangers interefering)
			legit_init(depths[closest_xpos][closest_ypos]);
			blob_search(closest_xpos,closest_ypos, depths[closest_xpos][closest_ypos]);
			
			if(get_blob_area()<500){
				printf("Go back to the BEGINNING!!!\n"); // Digimon the movie reference
				failcount++;
			}
			
			if(failcount>6){ // if it has pushed back more than 20 cm, hanger rack probably not visible at all
				if(get_blob_center()< 155){//error correction slot for small object (not rack) on left
					printf("Failed and turning away from object on left\n");
					break;
				}
				else{ //error correction slot for small object (not rack) on right
					printf("Failed and turning away from object on left\n");
					break;
				}
			}
		}
		cm = find_h(side); // find H shape
		//print_blobfield();
	} while(cm == -1); // if H shape not found, corrections have been made, try again
	
	open_claw(); // open claw for grabbing
	
	mrp(LIFTER, 1000, -2300); // move lifter into position
	block_motor_done(LIFTER);
	mrp(LIFTER, 1000, 175);
	block_motor_done(LIFTER);
	
	if(side == LEFT){ //execute proper grab and lift for each side
		drivecm(cm-28, -150); //-28 compensates for width of create and half a hanger
		close_claw_left();
		move_same();
	}
	else{
		drivecm(cm-29, -150);
		close_claw_right();
		move_opposite();
	}	
}


//utilities
int over_black(int port){ // returns whether tophat at port is over black
	return analog(port) > 557;
}

////driving
void drivecm(int cm, int speed) { // cm is  distance, speed is signed
	float drivecm_fudge = 0.9100;
	set_create_distance(0);
	create_drive_straight(speed);
	while (abs(get_create_distance(100000000)) < cm * 10 * drivecm_fudge);
	create_stop();
}

void line_follow(){ // drives along black tape until end, correcting angle while doing so
	create_drive_direct(-250, -250);
	while(over_black(LEFT_REFLECT)){
		if(over_black(RIGHT_REFLECT)){
			create_drive_direct(-205, -250);
		}
		if(!over_black(RIGHT_REFLECT)){
			create_drive_direct(-250, -205);
		}
		msleep(2);
	}
	create_drive_direct(0, 0);
}

void drive_until_black_parallel(){ //hit black tape, then parallel front of robot over it
	create_drive_direct(-250, -250); //speed is always 100
	while(!over_black(RIGHT_REFLECT) && !over_black(LEFT_REFLECT));
	if(!over_black(RIGHT_REFLECT)){
		while(!over_black(RIGHT_REFLECT));
		create_drive_direct(-15,0);
	}
	else{
		while(!over_black(LEFT_REFLECT));
		create_drive_direct(0, -15);

	}
	//msleep(630); //compensates for sensitivity of sensor
	create_drive_direct(0, 0);	
}

////turning
double to_degrees(double radians) {//convert from radians to degrees to utilize arctan()
	return radians*(180.0/PI);
}

void turn_until_black(){
	create_drive_direct(-70, 70);
	while(!over_black(LEFT_REFLECT)){
		msleep(5);
	}
	create_drive_direct(0, 0);
}

void turn_angle(int angle, int speed) { // angle absolute, speed signed
	const float FUDGE = .97; 
	const float FUDGE2 = 0;

	set_create_total_angle(0);
	create_drive_direct(speed, -speed);
	while (abs(get_create_total_angle(0.02)) < angle * FUDGE);

	create_stop();
}

int turn_to(int x, int y){ //returns cm to target
	//find distance to target
	if(x == 150 && y == -120){ //something went wrong, x, and y not initialized
		printf("failed initizialization\n");
		return -1;
	}
	printf("X: %d\n", x);
	printf("Y: %d\n", y);
	double X = x/10.0;
	double Y = y/10.0;
	int cm = (int)(sqrt(X*X + Y*Y));
	
	//find angle to target
	printf("cm: %d\n", cm);
	double ratio = (double)x/(double)y;
	printf("Ratio: %f\n", ratio);
	int angle_proper = (int)to_degrees(atan((double)x/(double)y))-8;
	printf("Angle: %d\n", angle_proper);
	if(abs(angle_proper) > 40){ // something went wrong, too much correction
		printf("angle was wrong\n");
		return -1;
	}	
	
	//ensure turning in the right direction
	if(angle_proper < 0){
		turn_angle(abs(angle_proper), -80);
	}
	else{
		turn_angle(angle_proper, 80);
	}
	return cm;	
}

void turn_left(){ //specific turn right for 90 degrees
	turn_angle(90, -100);
}

void turn_right(){ //specific turn right for 90 degrees
	turn_angle(90, 100);
}

////clawing
void servo_to(int port, int position){ // blocks program until servo reaches given position
	set_servo_position(port, position);
	while(get_servo_position(port) != position){
		msleep(10);
	}
}

void close_claw_right(){ //special claw closing to ensure good grip on right hanger
	servo_to(CLAW, CLAW_CLOSE*1/4);
	msleep(125);
	servo_to(CLAW, CLAW_CLOSE*2/4);
	msleep(200);
	turn_angle(8, -50);
	servo_to(CLAW, CLAW_CLOSE*3/4);
	msleep(125);
	close_claw();
}

void close_claw_left(){ //special claw closing to ensure good grip on right hanger
	servo_to(CLAW, CLAW_CLOSE*1/4);
	msleep(125);
	servo_to(CLAW, CLAW_CLOSE*2/4);
	msleep(200);
	turn_angle(8, 50);
	servo_to(CLAW, CLAW_CLOSE*3/4);
	msleep(125);
	drivecm(1, -100);
	close_claw();
}

void slow_open(){ //more carefully opens claw
	int i;
	for(i = CLAW_CLOSE; i >= CLAW_OPEN; i-=10){
		servo_to(CLAW, i);
		msleep(20);
	}
}

////lifting
void lift_arm(){ //lifts arm slowly to prevent damage
	/*
	servo_to(PIVOT, PIVOT_MIDDLE);
	msleep(500);

	servo_to(PIVOT, PIVOT_3Q);
	msleep(500);
	*/

	servo_to(PIVOT, PIVOT_UP);
	msleep(250);
}

void lift_to_top(){ // lifts lifter all the way to the top of the arm
	printf("Waiting \n");
	mav(LIFTER, 1000);
	while(digital(15) == 0){
		msleep(2);
		if(digital(15) == 1){
			msleep(15);
			if(digital(15) == 1){
				msleep(15);
				if(digital(15) == 1){
					break;
				}
			}
		}
	}
	printf("Done \n");
	mav(LIFTER,0);
	printf("REALLY DONE \n");
}

//blobbing
void get_pos_array(int lowerLim){  //establishes array of depths, and determines closest point
	int temp_z = 9999; //arbitrary big number
	int temp_x = 0;
	depth_update();

	int temp_col = 0;
	int temp_row = 0;

	int row; 
	int col;

	for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
		for(col = 0; col < SEARCH_WINDOW_WIDTH; col++){
			point3 p = get_depth_world_point(row, col);
			depths[col][row] = p.z;
			if(p.z < temp_z && !(p.z <= 500) && (p.z > lowerLim)){ // point should never be closer than 50 cm (xtion's active range), nor closer than established lower limit
				temp_z = p.z;
				temp_x = p.x;
				temp_row = row;
				temp_col = col;
			}
		}
	}
	closest_ypos = temp_row;
	closest_xpos = temp_col;
}

void init_blobfield(){ // clear and initiate blobfield
	int row; 
	int col;
	for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
		for(col = 0; col < SEARCH_WINDOW_WIDTH; col++){
			blob_field[col][row] = 0;
		}
	}
}

void blob_search(int i, int j, int last_depth){ // recursively build blob from closest point
	
	//tolerant of blobs that extend backwards, allowed up to 20 centimeters back from closest point
	if(!blob_field[i][j] && (depths[i][j]<=last_depth+10 && depths[i][j]>=last_depth-10) 
			&& (depths[i][j]<legit_level+200) &&(i>0)&&(i<SEARCH_WINDOW_WIDTH)&&(j>0)&&(j<SEARCH_WINDOW_HEIGHT)){ 
		//set point as searched
		blob_field[i][j] = 1;
		//search adjacent nodes
		blob_search(i-1, j-1, depths[i][j]);
		blob_search(i-1, j, depths[i][j]);
		blob_search(i-1, j+1, depths[i][j]);
		blob_search(i, j-1, depths[i][j]);
		blob_search(i, j+1, depths[i][j]);
		blob_search(i+1, j-1, depths[i][j]);
		blob_search(i+1, j, depths[i][j]);
		blob_search(i+1, j+1, depths[i][j]);
	}
}

void get_blob(){ //initializes first blob with practically no upper limit, aside from sanity
	init_blobfield();
	get_pos_array(9999);
	legit_init();
	blob_search(closest_xpos,closest_ypos, depths[closest_xpos][closest_ypos]);
}

int get_blob_area(){ // gets area of blob
	int row; 
	int col;
	int area = 0;
	for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
		for(col = 0; col < SEARCH_WINDOW_WIDTH; col++){
			if(blob_field[col][row]){
				area++;
			}
		}
	}
	return area;
}

void legit_init(){ //sets reference depth of closest point
	legit_level = depths[closest_xpos][closest_ypos];
}

void print_blobfield(){ //prints out blobfield WARNING: only use through ssh, prints take forever on Link
	int row; 
	int col;
	for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
		for(col = 0; col < SEARCH_WINDOW_WIDTH; col++){
			printf("%d", blob_field[col][row]);
		}
		printf("\n");
	}
}

int get_blob_center(){ //returns center column of blob
	return (int)((gright+gleft)/2);
}

int get_blob_width(){ //returns width of blob
	int left = -1;
	int right = -1;
	int row; 
	int col;
	for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
		for(col = 0; col < SEARCH_WINDOW_WIDTH; col++){
			if(blob_field[col][row]){
				if(left == -1){
					left = col;
				}
				if(col < left){
					left = col;
				}
				if(right == -1){
					right = col;
				}
				if(col > right){
					right = col;
				}
			} 
		}
	}
	gright = right;
	gleft = left;
	return (right-left);
}

int get_blob_height(){ //returns height of blob
	int top = -1;
	int bot = -1;
	int row; 
	int col;
	for(row = 0; row < SEARCH_WINDOW_HEIGHT; row++){
		for(col = 0; col < SEARCH_WINDOW_WIDTH; col++){
			if(blob_field[col][row]){
				if(top == -1){
					top = row;
				}
				if(row<top){
					top = row;
				}
				if(bot == -1){
					bot = row;
				}
				if(row>bot){
					bot = row;
				}
			} 
		}
	}
	return (bot-top);
}

//gamelogic
void setup(){
	
	//create setup
	create_connect();
	create_full();
	
	//motor setup
	enable_servo(CLAW);
	
	//lifter setup
	close_claw();
	clear_motor_position_counter(LIFTER);
	printf("xtion: %d\n", depth_open()); 
	//opens xtion and prints 1 if open
	
	wait_for_light(7);
	shut_down_in(118);
	start_time = seconds();
	enable_servo(PIVOT);
	lift_arm();
}

void hang_main(){ //hangs first three hangers
	//start lifting
	thread tid_lift = thread_create(lift_to_top);
	thread_start(tid_lift);
	
	//turn out of starting box
	turn_angle(70, 100);
	
	//setup for line following
	drive_until_black_parallel();
	drivecm(17,-200);
	
	turn_until_black();
	
	line_follow();
	
	thread_wait(tid_lift);
	thread_destroy(tid_lift);
	
	lift_to_top(); //double check that it's lifted to the top  
	
	//clears cube
	drivecm(8,-100);
	drivecm(21,-100);
	turn_angle(85, 150);
	drivecm(8, 100);
	turn_angle(10, 150);
	drivecm(8, -100);
	turn_angle(10, -150);
	
	drivecm(6,-100); //approach top hanger

	mrp(LIFTER, 1000, -125); //drops hangers on top
	block_motor_done(LIFTER);
	msleep(500);
	drivecm(8, 300);
	
	//releases hangers, clears tangles, and backs up
	slow_open();
	turn_angle(40, -100);
	turn_angle(38,100);
	msleep(500);
	
	//wait for Easter Bunny to pass
	drivecm(50, 300); 
	msleep(6500);
	drivecm(30, -300);
}

void move_opposite(){ //grabs and moves hangers facing opposite direction

	//lifts hanger off bottom rack
	mrp(LIFTER, 1000, 150);
	block_motor_done(LIFTER);
	drivecm(6, -100);
	mrp(LIFTER, 1000, -325);
	block_motor_done(LIFTER);
	drivecm(68, 300);
	
	//normalize further
	
	
	//hangs on top rack
	lift_to_top();
	while(seconds() < start_time + easter_bunny_pass_2);
	mrp(LIFTER, 1000, -750);
	block_motor_done(LIFTER);
	drivecm(55,-300);
	turn_angle(10, -100);
	turn_angle(10,100);
	mrp(LIFTER, 1000, 750);
	block_motor_done(LIFTER);
	drivecm(15, 100);
	open_claw();
	turn_angle(10, -100);
	turn_angle(10,100);
	drivecm(20, 100);
	
}

void move_same(){ //grabs and moves hangers facing same direction
	//remove hanger from bottom rack
	mrp(LIFTER, 1000, 250);
	block_motor_done(LIFTER);
	drivecm(8, 100);
	mrp(LIFTER, 1000, 400);
	block_motor_done(LIFTER);
	drivecm(30, 100);
	
	turn_left();
	drivecm(8, 300);
	
	//start lifting
	mav(LIFTER, 1000);
	drivecm(3, 300);
	
	turn_right();

	//wait for lifter to finish, then move hanger slightly below height of first rack
	while(!digital(15)){
		msleep(2);
	}
	printf("Done\n");
	mav(LIFTER, 0);

	//moves slightly above top rack
	lift_to_top();
	
	mrp(LIFTER, 1000, -315);
	block_motor_done(LIFTER);
	freeze(LIFTER);
	drivecm(35, -100);
	mrp(LIFTER, 1000, -100);
	block_motor_done(LIFTER);

	//release hangers
	open_claw();
	msleep(500);
	drivecm(39, 100);
}
