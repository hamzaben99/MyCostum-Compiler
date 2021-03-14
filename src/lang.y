%{

#include "Table_des_symboles.h"
#include "Attribute.h"

#include <stdio.h>
#include <string.h>
  
extern int yylex();
extern int yyparse();


FILE * pointc;
FILE * pointh;

void yyerror (char* s) {
  printf ("%s\n",s);
  }
		

%}

%union { 
	struct ATTRIBUTE * val;
  int num;
}
%token <val> NUMI NUMF
%token TINT TFLOAT //STRUCT
%token <val> ID
%token AO AF PO PF PV VIR
%token RETURN VOID EQ
%token <val> IF ELSE WHILE

%token <val> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%type <num>  while while_cond pointer bool_cond else elsop typename 
%type <val> exp type fun_head app funID params

%left DIFF EQUAL SUP INF       // low priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE

%start prog  
 


%%

prog : func_list               {}
;

func_list : func_list fun      {}
| fun                          {}
;


// I. Functions

fun : type fun_head fun_body    {}
;


fun_head : funID PO PF          {}
| funID PO params PF            {}
;

funID : ID                     {if(isdeclared($1->name) && $1->type_val ==  FUNC) p_error(strcat($1->name," is already declared"));
                                $1->type_val = FUNC;
                                $1->type_ret = $<val>0->type_val;
                                $1->count_pointer = $<val>0->count_pointer;
                                set_symbol_value($1->name, $1);
                                int n = new_label();
                                if(strcmp($1->name,"main") != 0) {
                                  fprintf(pointc, "void call_%s() {\n", $1->name);
                                }
                                if(strcmp($1->name,"main") == 0) {
                                  fprintf(pointc, "int main() {\n");
                                  fprintf(pointc, "sp = fp + 1;\n");
                                }
                                begin_block();
                                }
;

params: type ID vir params     {
                                 $2->type_val = ($1)->type_val;
                                 $2->count_pointer = ($1->count_pointer);
                                 $2->block_num = current_block();
                                 fprintf(pointh,"%s %s%s;\n",get_type($2),get_pointer($2->count_pointer),$2->name);
                                 $2->reg_number= new_reg($2);
                                 fprintf(pointc,"r%d=*(--sp);\n",$2->reg_number);
                                 fprintf(pointc,"%s = r%d;\n",$2->name,$2->reg_number);
                                 set_symbol_value($2->name,$2);}
| type ID                      {
                                 $2->type_val = $1->type_val;
                                 $2->count_pointer = ($1->count_pointer);
                                 $2->block_num = current_block();
                                 fprintf(pointh,"%s %s%s;\n",get_type($2),get_pointer($2->count_pointer),$2->name);
                                 $2->reg_number= new_reg($2);
                                 fprintf(pointc,"r%d=*(--sp);\n",$2->reg_number);
                                 fprintf(pointc,"%s = r%d;\n",$2->name,$2->reg_number);
                                 set_symbol_value($2->name,$2);}

vlist: vlist vir ID            {if(isdeclared($3->name) && get_symbol_value($3->name)->block_num == current_block()) p_error(strcat($3->name," is already declared"));
                                $3->type_val = $<val>0->type_val;
                                $3->count_pointer = $<val>0->count_pointer;
                                $3->block_num = current_block();
                                fprintf(pointh, "%s %s%s;\n", get_type($3), get_pointer($3->count_pointer), $3->name);
                                set_symbol_value($3->name, $3);
                                if($3->count_pointer > 0) {
                                  fprintf(pointc, "%s = (%s%s)malloc(sizeof(%s%s));\n", $3->name, get_type($3), get_pointer($3->count_pointer), get_type($3), get_pointer($3->count_pointer -1));
                                }}
| ID                           {
                                if(isdeclared($1->name) && get_symbol_value($1->name)->block_num == current_block())p_error(strcat($1->name," is already declared"));
                                $1->type_val = $<val>0->type_val;
                                $1->count_pointer = $<val>0->count_pointer;
                                $1->block_num = current_block();
                                fprintf(pointh, "%s %s%s;\n", get_type($1), get_pointer($1->count_pointer), $1->name);
                                set_symbol_value($1->name, $1);
                                
                                if($1->count_pointer > 0) {
                                  fprintf(pointc, "%s = (%s%s)malloc(sizeof(%s%s));\n", $1->name, get_type($1), get_pointer($1->count_pointer), get_type($1), get_pointer($1->count_pointer -1));
                                }}
;

vir : VIR                      {}
;

fun_body : AO block AF   {
                                if(strcmp($<val>0->name, "main") == 0) {
                                  fprintf(pointc, "printf(\"Number of function calls: %s\\n\", endFunc);//FOR DEBUG\n", "%d");
                                  fprintf(pointc, "return 0;\n");
                                }
                                else fprintf(pointc, "endFunc ++;//FOR DEBUG\n");
                                fprintf(pointc, "}\n");
                                end_block();}
;

// Block
block:
decl_list inst_list            {}
;

openBlock: AO                  {begin_block();}
;
// I. Declarations

decl_list : decl_list decl     {}
|                              {}
;

decl: var_decl PV              {}
;

var_decl : type vlist          {}
;

type
: typename pointer            {attribute a = new_attribute ();
                                a->type_val = $1;
                                a->count_pointer = $2;
                                $$ = a;}

| typename                    {attribute a = new_attribute ();
                                a->type_val = $1;
                                a->count_pointer = 0;
                                $$ = a;
                                }
;

typename
: TINT                         {$$ = INT;}
| VOID                         {$$ = VD;}
| TFLOAT                       {$$ = FLOAT;}
;

pointer
: pointer STAR                 {$$ = $1 + 1;}
| STAR                         {$$ = 1;}
;


// II. Intructions

inst_list: inst PV inst_list {}
| inst pvo                   {}
;

pvo : PV
|
;


inst:
exp                           {}
| openBlock block AF          {end_block();}
| aff                         {}
| ret                         {}
| cond                        {}
| loop                        {}
| PV                          {}
;


// II.1 Affectations

aff : ID EQ exp               {attribute x = get_symbol_value($1->name);
                              
                              if(!compatible_type(x,$3))
                                fprintf(pointc, "%s = (%s)r%d;\n", x->name, get_type(x), $3->reg_number);
                              else                               
                                fprintf(pointc, "%s = r%d;\n", x->name, $3->reg_number);

                              if (x->count_pointer == 0) fprintf(pointc, "printf(\"%s = %s\\n\", %s);\n", x->name, "%d", x->name);
                              else fprintf(pointc, "printf(\"%s = %s -- *%s = %s\\n\", %s, *%s);\n", x->name, "%p", x->name, "%d", x->name, x->name);}

| STAR exp  EQ exp            {attribute x = get_symbol_value($2->name);
                              attribute c = copy_attribute(x);
                              c->count_pointer --;
                              x->reg_number = new_reg(x);
                              fprintf(pointc, "r%d = %s;\n",x->reg_number,x->name);
                              if(compatible_type(c,$4))
                                fprintf(pointc, "*r%d = r%d;\n", x->reg_number, $4->reg_number);
                              else
                                fprintf(pointc, "*r%d = (%s)r%d;\n", x->reg_number, get_type(x), $4->reg_number);
                              fprintf(pointc, "printf(\"%s = %s -- *%s = %s\\n\", %s, *%s);\n", x->name, "%p", x->name, "%d", x->name, x->name);
}
                                                                                                             
;


// II.2 Return
ret : RETURN exp              {fprintf(pointc,"*(fp)=(long int)r%d;\n",$2->reg_number);}
| RETURN PO PF                {}
;

// II.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction qui est résolu comme on le souhaite
//           i.e. en lisant un ELSE en entrée, si on peut faire une reduction elsop, on la fait...

cond :
if bool_cond inst elsop       {fprintf(pointc,"label%d:\n",$4); }
;

elsop : else inst             {$$ = $1;}
|                             {$$ = $<num>-1;}
;

bool_cond : PO exp PF         {int x = new_label();
                              fprintf(pointc,"if (!r%d) goto label%d ;\n",$2->reg_number,x);
                              $$ = x ; }
;

if : IF                       {}
;

else : ELSE                   {int x = new_label();
                              fprintf(pointc,"goto label%d ;\nlabel%d:\n",x,$<num>-1);
                              $$ = x ;}
;

// II.4. Iterations

loop : while while_cond inst  {fprintf(pointc, "goto label%d;\nlabel%d:\n", $1, $2);}
;

while_cond : PO exp PF        {int x = new_label();
                              fprintf(pointc,"if (!r%d) goto label%d;\n", $2->reg_number, x);
                              $$ = x;}

while : WHILE                 {int x = new_label();
                              fprintf(pointc,"label%d:\n", x);
                              $$ = x;}
;

// II.3 Expressions
exp:
// II.3.0 Exp. arithmetiques
MOINS exp %prec UNA           {attribute x = neg_attribute($2); $$ = x;}
| exp PLUS exp                {attribute x = plus_attribute($1, $3); $$ = x;}
| exp MOINS exp               {attribute x = minus_attribute($1, $3); $$ = x;}
| exp STAR exp                {attribute x = mult_attribute($1, $3); $$ = x;}
| exp DIV exp                 {attribute x = div_attribute($1, $3); $$ = x;}
| PO exp PF                   {$$ = $2;}
| ID                          {attribute x = get_symbol_value($1->name);
                              x->reg_number = new_reg(x);
                              if(!is_in_block(x)) p_error(strcat(x->name," is not declared"));
                                fprintf(pointc, "r%d = %s;\n", x->reg_number, x->name);
                              $$ = x;}
| app                         {$$=$1;}
| NUMI                        {$1->reg_number = new_reg($1); fprintf(pointc,"r%d = %s;\n",$1->reg_number,$1->name); $$ = $1;}
| NUMF                        {$1->reg_number = new_reg($1); fprintf(pointc,"r%d = %s;\n",$1->reg_number,$1->name); $$ = $1;}

// II.3.1 Déréférencement

| STAR exp %prec UNA          {attribute x = copy_attribute($2);
                              x->count_pointer --;                      
                              x->reg_number = new_reg(x);
                              fprintf(pointc,"r%d = *r%d;\n",x->reg_number,$2->reg_number);
                              $$ = x; 

                     
}

// II.3.2. Booléens

| NOT exp %prec UNA           {attribute x = not_attribute($2); $$ = x;}
| exp INF exp                 {attribute x = inf_attribute($1, $3); $$ = x;}
| exp SUP exp                 {attribute x = sup_attribute($1, $3); $$ = x;}
| exp EQUAL exp               {attribute x = equal_attribute($1, $3); $$ = x;}
| exp DIFF exp                {attribute x = diff_attribute($1, $3); $$ = x;}
| exp AND exp                 {attribute x = and_attribute($1, $3); $$ = x;}
| exp OR exp                  {attribute x = or_attribute($1, $3); $$ = x;}
;

// II.4 Aplcations de fonctions

app : ID openAPP args PF      {attribute x =  get_symbol_value($1->name);
                              if (x->type_val != FUNC) p_error(strcat(x->name," is not a function"));      
                              fprintf(pointc,"call_%s();\n", x->name);
                              if (x->type_ret != VD) {
                                attribute r = new_attribute();
                                r->type_val = x->type_ret;
                                r->count_pointer = x->count_pointer;
                                r->reg_number = new_reg(r);
                                fprintf(pointc,"r%d=(%s%s)*fp;\n", r->reg_number, get_type(r), get_pointer(r->count_pointer));            
                                fprintf(pointc,"fp=(long int*)*(fp-1);\n");                  
                                fprintf(pointc,"sp=fp+1;\n");                    
                                $$ = r;
                              }
                              else {
                                $$ = NULL;
                              }}
;
openAPP : PO                   {fprintf(pointc,"*sp=(long int)fp;\nsp++;\n");                  
                                fprintf(pointc,"fp=sp++;\n");}

args :  arglist               {}
|                             {}
;

arglist : arglist VIR exp     {fprintf(pointc, "*(sp++)=r%d;\n", $3->reg_number);}
| exp                         {fprintf(pointc, "*(sp++)=r%d;\n", $1->reg_number);}
;



%% 
int main (int argc,char* argv[]) { 
  pointc = fopen(argv[2], "w");
  pointh = fopen(argv[1], "w");

  fprintf(pointc, "#include \"../%s\"\n", argv[1]);

  fprintf(pointh, "#ifndef _TEST_H_\n");
  fprintf(pointh, "#define _TEST_H_\n");
  fprintf(pointh, "#include <stdlib.h>\n");
  fprintf(pointh, "#include <stdio.h>\n");
  fprintf(pointh, "#define PILE_SIZE 255\n");
  fprintf(pointh, "int endFunc = 0;//FOR DEBUG\n");
  fprintf(pointh, "long int  pile[PILE_SIZE];\n");
  fprintf(pointh, "long int *fp = pile;\n");
  fprintf(pointh, "long int *sp;\n");
  

  yyparse ();

  fprintf(pointh, "#endif\n");

  fclose(pointc);
  fclose(pointh);
  return 0;
} 

