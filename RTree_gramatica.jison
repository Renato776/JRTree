/**
 * Ejemplo mi primer proyecto con Jison utilizando Nodejs en Ubuntu
 */

/* Definición Léxica */
%lex

%options case-insensitive

%%

"<"([^<>\\]|\\.)*">" return 'DATO';
[0-9a-zA-Z_]+ return 'IDENTIFIER';

"{"          return 'LEFT_BRACE';
"}"          return 'RIGHT_BRACE';
"["          return 'LEFT_BRACKET';
"]"          return 'RIGHT_BRACKET';
"|"          return 'PIPE';
":"          return 'DOUBLE_COLON'

[ \r\t]+            {/*Ignore*/}
\n                  {/*Ignore*/}
<<EOF>>                 return 'EOF';

.                       { console.error('Este es un error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column); }
/lex

%start s

%% /* Definición de la gramática */

s
	: inicio {/* Se termino el parsing!! evaluate($1) */
	context.root = ($1);
	}
;

inicio : nodo EOF { $$ = $1; }
        ;

nodo : LEFT_BRACE data nodoL RIGHT_BRACE { res = context.new_g_node("nodo"); res.add($2); res.add($3); $$ = res; }
		;

data : LEFT_BRACKET fieldL RIGHT_BRACKET { res = context.new_g_node("data"); res.add($2); $$ = res; }
		| /*empty*/ { $$ = context.new_g_node("data"); }
		;
		
fieldL : fieldL PIPE field  { $1.add($3); $$ = $1; }
			| field { res = context.new_g_node("fields"); res.add($1); $$ = res; }
			;
			
field : IDENTIFIER DOUBLE_COLON DATO {wrapper = context.new_g_node("field"); 
wrapper.add(
context.new_g_node_from_token(context.new_l_token("id",0, yylineno, $1, false))
);
wrapper.add(
context.new_g_node_from_token(context.new_l_token("dato",0, yylineno, $3, true))
); $$ = wrapper; }
		| IDENTIFIER DOUBLE_COLON nodo { wrapper = context.new_g_node("field"); 
		wrapper.add(
		context.new_g_node_from_token(context.new_l_token("id",0, yylineno, $1, false))
		); wrapper.add($3); $$ = wrapper; }
		| IDENTIFIER DOUBLE_COLON data { wrapper = context.new_g_node("field"); 
		wrapper.add(
		context.new_g_node_from_token(context.new_l_token("id",0, yylineno, $1, false))
		); wrapper.add($3); $$ = wrapper; }
		;
nodoL : nodoL nodo { $1.add($2); $$ = $1; }
		| /*empty*/ { $$ = context.new_g_node("children"); }
		;
