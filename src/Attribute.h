/*
 *  Attribute.h
 *
 *  Created by Janin on 10/2019
 *  Copyright 2018 LaBRI. All rights reserved.
 *
 *  Module for a clean handling of attibutes values
 *
 */

#ifndef ATTRIBUTE_H
#define ATTRIBUTE_H

typedef enum {VD, INT, FLOAT, FUNC} type;
/**
 * FUNC: A function type to differentiate between a function call and variable.
 * VD: A void type. For example a function that doesn't have a return type.
 * */

struct ATTRIBUTE {
  char * name; //The name of the ID
  //int int_val; //Used for TINT
  //float float_val; //Used for float operations
  type type_val; //Type of the attribute (VD: void, INT: int, FLOAT: float, FUNC: function)
  int reg_number; //Register number of the attribute
  
  /* other attribute's fields can goes here */
  
  type type_ret; //Type of the return value of a function

  int block_num; //The number of block where the attribute is declared

  int count_pointer; //The number of stars in a pointer (0 means the variable is not a pointer)

};

typedef struct ATTRIBUTE * attribute;

attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */

attribute copy_attribute(attribute x);
/*returns the pointer to a a newly allocated attribute copy of x */

int compatible_type(attribute a, attribute b);
/*returns 1 if the attributes a and b are of the same type. 0 otherwise */

char* get_type(attribute a);
char* get_pointer(int n);

void p_error(char* error_description);

//arithmetic
attribute plus_attribute(attribute x, attribute y);
attribute mult_attribute(attribute x, attribute y);
attribute minus_attribute(attribute x, attribute y);
attribute div_attribute(attribute x, attribute y);
attribute neg_attribute(attribute x);

//Bool
attribute not_attribute(attribute x);
attribute inf_attribute(attribute x, attribute y);
attribute sup_attribute(attribute x, attribute y);
attribute equal_attribute(attribute x, attribute y);
attribute diff_attribute(attribute x, attribute y);
attribute and_attribute(attribute x, attribute y);
attribute or_attribute(attribute x, attribute y);

//Labels and Registers
int new_label(); //Returns a new label number.
int new_reg(); //Returns a new register number.

//Blocks
void begin_block(); //Called when entring a new block (AO)
void end_block(); //Called when exiting a block (AF)
int current_block(); //Returns the number of current block
int is_in_block(attribute x); //Predicate : Returns 1 (true) when the attribute is in the scope i.e declared in the current blocks, 0 (false) else.



#endif

