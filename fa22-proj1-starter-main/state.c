#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t* state, unsigned int snum);
static char next_square(game_state_t* state, unsigned int snum);
static void update_tail(game_state_t* state, unsigned int snum);
static void update_head(game_state_t* state, unsigned int snum);

/* Task 1 */
game_state_t* create_default_state() {
  // TODO: Implement this function.
  char a[21]="####################\0";
  char b[21]="# d>D    *         #\0";
  char c[21]="#                  #\0";
  game_state_t* state = malloc(sizeof(game_state_t));
  if(state==NULL) return NULL;
  state->num_rows=18;
  state->num_snakes=1;
  state->snakes = malloc(sizeof(snake_t));
  if(state->snakes==NULL){
    free(state);
    return NULL;
  }
  state->snakes->live=true;
  state->snakes->head_row=2;
  state->snakes->head_col=4;
  state->snakes->tail_row=2;
  state->snakes->tail_col=2;
  state->board = malloc(state->num_rows*sizeof(char*));
  if(state->board==NULL){
    free(state->snakes);
    free(state);
  }
  for(int i=0;i<state->num_rows;i++){
    state->board[i] = malloc(21*sizeof(char));
    if(state->board[i]==NULL){
      for(int j=0;j<i;j++) free(state->board[j]);
      free(state->board);
      free(state->snakes);
      free(state);
      return NULL;
    }
    if(i==0||i==state->num_rows-1)  strcpy(state->board[i],a);
    else if(i==2)  strcpy(state->board[i],b);
    else  strcpy(state->board[i],c);
  }
  return state;
}

/* Task 2 */
void free_state(game_state_t* state) {
  // TODO: Implement this function.
  free(state->snakes);
  for(int i=0;i<state->num_rows;i++){
    free(state->board[i]);
  }
  free(state->board);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
  // TODO: Implement this function.
  for(int i=0;i<state->num_rows;i++) fprintf(fp,"%s\n",state->board[i]);
  return;
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t* state, char* filename) {
  FILE* f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t* state, unsigned int row, unsigned int col) {
  return state->board[row][col];
}

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  return c=='w'||c=='a'||c=='s'||c=='d';
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  return c=='W'||c=='A'||c=='S'||c=='D'||c=='x';
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  // TODO: Implement this function.
  return is_tail(c)||is_head(c)||c=='^'||c=='<'||c=='>'||c=='v';
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  if(c=='^') return 'w';
  else if(c=='<') return 'a';
  else if(c=='v') return 's';
  else return 'd';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
  if(c=='W') return '^';
  else if(c=='A') return '<';
  else if(c=='S') return 'v';
  else return '>';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  if(c=='v'||c=='s'||c=='S') return cur_row+1;
  else if(c=='^'||c=='w'||c=='W') return cur_row-1;
  else return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
  if(c=='>'||c=='d'||c=='D') return cur_col+1;
  else if(c=='<'||c=='a'||c=='A') return cur_col-1;
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  char head=get_board_at(state,state->snakes[snum].head_row,state->snakes[snum].head_col);
  return get_board_at(state,get_next_row(state->snakes[snum].head_row,head),get_next_col(state->snakes[snum].head_col,head));
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  char head=get_board_at(state,state->snakes[snum].head_row,state->snakes[snum].head_col);
  char body=head_to_body(head);
  unsigned int curRow=state->snakes[snum].head_row;
  unsigned int curCol=state->snakes[snum].head_col;
  unsigned int nextRow=get_next_row(curRow,head);
  unsigned int nextCol=get_next_col(curCol,head);
  set_board_at(state,nextRow,nextCol,head);
  set_board_at(state,curRow,curCol,body);
  state->snakes[snum].head_row=nextRow;
  state->snakes[snum].head_col=nextCol;
  return;
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int curRow=state->snakes[snum].tail_row;
  unsigned int curCol=state->snakes[snum].tail_col;
  char tail=get_board_at(state,curRow,curCol);
  unsigned int nextRow=get_next_row(curRow,tail);
  unsigned int nextCol=get_next_col(curCol,tail);
  char body=get_board_at(state,nextRow,nextCol);
  set_board_at(state,curRow,curCol,' ');
  set_board_at(state,nextRow,nextCol,body_to_tail(body));
  state->snakes[snum].tail_row=nextRow;
  state->snakes[snum].tail_col=nextCol;
  return;
}

/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
  // TODO: Implement this function.
  for(unsigned int i=0;i<state->num_snakes;i++){
    char x=next_square(state,i);
    if(is_snake(x)||x=='#'){
      set_board_at(state,state->snakes[i].head_row,state->snakes[i].head_col,'x');
      state->snakes[i].live=false;
    }else if(x=='*'){
      update_head(state,i);
      add_food(state);
    }else{
      update_head(state,i);
      update_tail(state,i);
    }
  }
  return;
}

/* Task 5 */
game_state_t* load_board(char* filename) {
  // TODO: Implement this function.
  char data1[255];
  FILE* fp=fopen(filename,"r");
  if(fp==NULL) return NULL;
  game_state_t *state = malloc(sizeof(game_state_t));
  char c;
  long unsigned int fileRow=0;
  while((c=(char)fgetc(fp))!=EOF){
    if(c=='\n') fileRow++;
  }
  state->board = malloc(fileRow*sizeof(char*));
  rewind(fp);
  for(int i=0;fgets(data1,255,fp);i++){
    state->board[i] = malloc((strlen(data1)+1)*sizeof(char));
    strcpy(state->board[i],data1);
    state->board[i][strlen(data1)-1]='\0';
  }
  state->num_rows=(unsigned int)fileRow;
  fclose(fp);
  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  char curr = get_board_at(state,state->snakes[snum].tail_row,state->snakes[snum].tail_col);
  unsigned int nextRow=get_next_row(state->snakes[snum].tail_row,curr);
  unsigned int nextCol=get_next_col(state->snakes[snum].tail_col,curr);
  char x = get_board_at(state,nextRow,nextCol);
  while(!is_head(x)){
    nextRow=get_next_row(nextRow,x);
    nextCol=get_next_col(nextCol,x);
    x=get_board_at(state,nextRow,nextCol);
  }
  state->snakes[snum].head_row=nextRow;
  state->snakes[snum].head_col=nextCol;
  state->snakes[snum].live=true;
  return;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
  // TODO: Implement this function.
  unsigned int num=0;
  unsigned int row[100];
  unsigned int col[100];
  for(unsigned int i=0;i<state->num_rows;i++){
    for(unsigned int j=0;j<strlen(state->board[i]);j++){
      if(is_tail(get_board_at(state,i,j))){
        row[num]=i;
        col[num]=j;
        num++;
      }
    }
  }
  state->num_snakes=num;
  state->snakes = malloc(state->num_snakes*sizeof(snake_t));
  for(unsigned int i=0;i<num;i++){
    state->snakes[i].tail_row=row[i];
    state->snakes[i].tail_col=col[i];
    state->snakes[i].live=true;
    find_head(state,i);
  }
  return state;
}
