extends "res://test/ld_test.gd"

func run() -> void:
	await tree.process_frame
	var TT = TokenSystem.TokenType

	section("keywords")
	var lex = Lexer.new()
	var toks = lex.tokenize("if else for while function return")
	assert_true(lex.errors.is_empty(), "no errors on keywords")
	assert_eq(toks[0].type, TT.IF, "if")
	assert_eq(toks[1].type, TT.ELSE, "else")
	assert_eq(toks[2].type, TT.FOR, "for")
	assert_eq(toks[3].type, TT.WHILE, "while")
	assert_eq(toks[4].type, TT.FUNCTION, "function")
	assert_eq(toks[5].type, TT.RETURN, "return")
	assert_eq(toks[toks.size() - 1].type, TT.EOF, "ends with EOF")

	section("numbers")
	var t2 = Lexer.new().tokenize("42 3.14")
	assert_eq(t2[0].type, TT.NUMBER, "int is a number token")
	assert_eq(t2[0].value, 42, "int value")
	assert_eq(t2[1].value, 3.14, "float value")

	section("operators")
	var t3 = Lexer.new().tokenize("== != <= >= = + - * / %")
	var expected = [TT.EQUALS, TT.NOT_EQUALS, TT.LESS_EQUAL, TT.GREATER_EQUAL,
			TT.ASSIGN, TT.PLUS, TT.MINUS, TT.MULTIPLY, TT.DIVIDE, TT.MODULO]
	for i in range(expected.size()):
		assert_eq(t3[i].type, expected[i], "operator index %d" % i)

	section("comments are skipped")
	var lex4 = Lexer.new()
	lex4.tokenize("x = 5 # hash comment\ny = 6 // slash comment")
	assert_true(lex4.errors.is_empty(), "no errors with comments")

	section("no 'var' keyword — lexes as identifier")
	var t5 = Lexer.new().tokenize("var")
	assert_eq(t5[0].type, TT.IDENTIFIER, "'var' is a plain identifier")

	section("boolean & null literals")
	var tb = Lexer.new().tokenize("true false null")
	assert_eq(tb[0].type, TT.TRUE, "true is a TRUE token")
	assert_eq(tb[1].type, TT.FALSE, "false is a FALSE token")
	assert_eq(tb[2].type, TT.NULL, "null is a NULL token")

	section("errors are recorded")
	var lex6 = Lexer.new()
	lex6.tokenize("x = @")
	assert_false(lex6.errors.is_empty(), "unknown character recorded")
	var lex7 = Lexer.new()
	lex7.tokenize("name = \"unterminated")
	assert_false(lex7.errors.is_empty(), "unterminated string recorded")
