#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_BLOCKS 255
#define MAX_POINTER 20

extern FILE * pointh;
extern FILE * pointc;

attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  return r;
};

void p_error(char* error_description) {
  fprintf(stderr, "Error: %s\n", error_description);
  exit(-1);
}

attribute copy_attribute(attribute x){
  attribute c = malloc(sizeof(struct ATTRIBUTE));
  memcpy(c,x,sizeof(struct ATTRIBUTE));
  return c ; 
}


int compatible_type(attribute a, attribute b) {
  if ((a->type_val != INT && a->type_val != FLOAT) || 
      (b->type_val != INT && b->type_val != FLOAT))
      p_error("incompatible type");
  if (a->count_pointer == b->count_pointer) {
    return a->type_val == b->type_val;
  }
  else {
    p_error("operation not supported");
  }
}

char* get_type(attribute a) {
  switch (a->type_val)
  {
  case INT:
    return "int";
    break;
  case FLOAT:
    return "float";
    break;
  case VD:
    return "void";
    break;
  default:
    return "void";
    break;
  }
}

char* get_pointer(int n ) {
  int i = 0;
  char *star = malloc(sizeof(char) *(MAX_POINTER));
  while(i < n) {
    strcat(star, "*");
    i++;
  }
  return star;
}

void print_op(attribute r, attribute x, char *operation, attribute y, int is_compatible) {
  r->reg_number = new_reg(r);
  fprintf(pointc,"r%d = %sr%d %s %sr%d;\n",
            r->reg_number,
            (!is_compatible && x->type_val != FLOAT)?"(float)":"",x->reg_number,
            operation,
            (!is_compatible && y->type_val != FLOAT)?"(float)":"",y->reg_number);
}

void print_arthm(attribute r, attribute x, char *operation, attribute y) {
  int is_compatible = compatible_type(x,y);
  if(is_compatible) r->type_val = x->type_val;
  else                    r->type_val = FLOAT;
  print_op(r,x,operation,y,is_compatible);
}

attribute plus_attribute(attribute x, attribute y) {
  
  attribute r = new_attribute();
  print_arthm(r, x, "+", y);
  return r;
};

attribute mult_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  print_arthm(r, x, "*", y);
  return r;
};

attribute minus_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  print_arthm(r, x, "-", y);
};

attribute div_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  print_arthm(r, x, "/", y);
  return r;
};

attribute neg_attribute(attribute x){
  attribute r = new_attribute();
  r->type_val = x->type_val;
  r->reg_number = new_reg(r);
  fprintf(pointc, "r%d = - r%d;\n",r->reg_number,x->reg_number);
  return r;
};
//Bool 

attribute not_attribute(attribute x){
  attribute r = new_attribute();
  r->type_val = x->type_val;
  r->reg_number = new_reg(r);
  fprintf(pointc, "r%d = !r%d;\n",r->reg_number,x->reg_number);
  return r;
}

attribute inf_attribute(attribute x, attribute y) {
  attribute r = new_attribute();
  r->type_val = x->type_val;
  print_op(r, x, "<", y, 1);
  return r;
}

attribute sup_attribute(attribute x, attribute y) {
  attribute r = new_attribute();
  r->type_val = x->type_val;
  print_op(r, x, ">", y, 1);
  return r;
}
attribute equal_attribute(attribute x, attribute y) {
  attribute r = new_attribute();
  r->type_val = x->type_val;
  print_op(r, x, "==", y, 1);
  return r;
}
attribute diff_attribute(attribute x, attribute y) {
  attribute r = new_attribute();
  r->type_val = x->type_val;
  print_op(r, x, "!=", y, 1);
  return r;
}
attribute and_attribute(attribute x, attribute y) {
  attribute r = new_attribute();
  r->type_val = x->type_val;
  print_op(r, x, "&&", y, 1);
  return r;
}
attribute or_attribute(attribute x, attribute y) {
  attribute r = new_attribute();
  r->type_val = x->type_val;
  print_op(r, x, "||", y, 1);
  return r;
}
//Register and Label

int reg_counter = 1;

int new_reg(attribute a) {
  fprintf(pointh,"%s %sr%d;\n",get_type(a),get_pointer(a->count_pointer),reg_counter);
  return reg_counter++;
}

int label_counter = 1;

int new_label() {
  return label_counter++;
}
//Block

int block_number = 1;
int block_stack[MAX_BLOCKS];
int block_position = 0;

void begin_block() {
  block_stack[block_position] = block_number;
  block_number++;
  block_position++;
}

void end_block() {
  block_position--;
}

int current_block() {
  return block_stack[block_position - 1];
}

int is_in_block(attribute x){
  int i = 0;
  for(i = 0; i < block_position; i++) {
    if(x->block_num == block_stack[i]) return 1;
  }
  return 0;
}
