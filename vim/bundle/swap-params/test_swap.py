import SwapParams

class TestSwap(object):

    def test_simple_case(self):
        self.assertSwaps("fun(par|m|1, parm2)", 
                            "fun(parm2, parm|1|)")

    def test_simple_case_backwards(self):
        self.assertSwapsBackwards("fun(parm2, par|m|1)",
                                     "fun(|p|arm1, parm2)")

    def test_nested_call_as_an_arg(self):
        self.assertSwaps("fun(par|m|1(), parm2)", 
                            "fun(parm2, parm1(|)|)")

    def test_nested_call_as_an_arg_backwards(self):
        self.assertSwapsBackwards("fun(parm2, par|m|1())", 
                                     "fun(|p|arm1(), parm2)")

    def test_cursor_on_a_bracket_of_a_nested_call(self):
        self.assertSwaps("fun(parm1(|)|, parm2)", 
                            "fun(parm2, parm1(|)|)")

    def test_cursor_on_a_bracket_of_a_nested_call_backwards(self):
        self.assertSwapsBackwards("fun(parm2, parm1(|)|)", 
                                     "fun(|p|arm1(), parm2)")

    def test_nested_call_with_one_arg(self):
        self.assertSwaps("fun(parm|1|(arg), parm2)", 
                            "fun(parm2, parm1(arg|)|)",)

    def test_nested_call_with_one_arg_backwards(self):
        self.assertSwapsBackwards("fun(parm2, parm|1|(arg))", 
                                     "fun(|p|arm1(arg), parm2)",)

    def test_nested_call_with_two_args(self):
        self.assertSwaps("fun(parm|1|(arg,arg2), parm2)", 
                            "fun(parm2, parm1(arg,arg2|)|)")

    def test_nested_call_with_two_args_backwards(self):
        self.assertSwapsBackwards("fun(parm2, parm|1|(arg,arg2))", 
                                     "fun(|p|arm1(arg,arg2), parm2)")

    def test_cursor_on_opening_bracket_of_a_nested_call(self):
        self.assertSwaps("fun(parm1|(|arg,arg2), parm2)", 
                            "fun(parm2, parm1(arg,arg2|)|)")

    def test_cursor_on_opening_bracket_of_a_nested_call_backwards(self):
        self.assertSwapsBackwards("fun(parm2, parm1|(|arg,arg2))", 
                                     "fun(|p|arm1(arg,arg2), parm2)")

    def test_cursor_on_closing_bracket_of_a_nested_call(self):
        self.assertSwaps("fun(parm1(arg,arg2|)|, parm2)", 
                            "fun(parm2, parm1(arg,arg2|)|)")

    def test_cursor_on_closing_bracket_of_a_nested_call_backwards(self):
        self.assertSwapsBackwards("fun(parm2, parm1(arg,arg2|)|)", 
                                     "fun(|p|arm1(arg,arg2), parm2)")

    def test_spaces_inside_nested_call(self):
        self.assertSwaps("fun(parm1(arg, arg2|)|, parm2)", 
                            "fun(parm2, parm1(arg, arg2|)|)")

    def test_spaces_inside_nested_call_backwards(self):
        self.assertSwapsBackwards("fun(parm2, parm1(arg, arg2|)|)", 
                                     "fun(|p|arm1(arg, arg2), parm2)")

    def test_three_args(self):
        self.assertSwaps("fun(arg1, ar|g|2, arg3)", 
                            "fun(arg1, arg3, arg|2|)")

    def test_three_args_backwards(self):
        self.assertSwapsBackwards("fun(arg1, ar|g|2, arg3)", 
                                     "fun(|a|rg2, arg1, arg3)")

    def test_three_args_backwards_fix_for_a_defect(self):
        self.assertSwapsBackwards("fun(arg1, arg2, ar|g|3)", 
                                     "fun(arg1, |a|rg3, arg2)")

    def test_square_brackets(self):
        self.assertSwaps("array[a|r|g1, arg2]", "array[arg2, arg|1|]")

    def test_square_brackets_backwards(self):
        self.assertSwapsBackwards("array[arg2, a|r|g1]", "array[|a|rg1, arg2]")

    def test_nested_square_brackets(self):
        self.assertSwaps("fun(par|m|1[], parm2)", "fun(parm2, parm1[|]|)")
        self.assertSwaps("fun(parm1[|]|, parm2)", "fun(parm2, parm1[|]|)")

    def test_nested_square_brackets_backwards(self):
        self.assertSwapsBackwards("fun(parm2, par|m|1[])", "fun(|p|arm1[], parm2)")
        self.assertSwapsBackwards("fun(parm2, parm1[|]|)", "fun(|p|arm1[], parm2)")

    def test_array_access_as_the_second_param(self):
        self.assertSwaps("fun(par|m|1, array[])", "fun(array[], parm|1|)")
        
    def test_array_access_as_the_second_param_backwards(self):
        self.assertSwapsBackwards("fun(array[], par|m|1)", "fun(|p|arm1, array[])")
        
    def test_preserving_spacing(self):
        self.assertSwaps("fun(|a|,b)", "fun(b,|a|)")

    def test_preserving_spacing_backwards(self):
        self.assertSwapsBackwards("fun(b,|a|)", "fun(|a|,b)")

    def test_fix_for_a_defect(self):
        self.assertSwaps("[(p1, p2|)|, p3]", "[p3, (p1, p2|)|]")

    def test_Konrads_example(self):
        self.assertSwaps("for |a|, b in some_dict.items()",
                         "for b, |a| in some_dict.items()")

    def test_Konrads_example_backwards(self):
        self.assertSwapsBackwards("for a, |b| in some_dict.items()",
                         "for |b|, a in some_dict.items()")

    def test_swap_imports(self):
        self.assertSwaps("from os import |p|open, path",
                         "from os import path, pope|n|")

    def test_swap_imports_backwards(self):
        self.assertSwapsBackwards("from os import popen, pat|h|",
                                  "from os import |p|ath, popen")

    def test_swap_no_left_delimiter(self):
        self.assertSwaps("|t|wo, one", "one, tw|o|")

    def test_swap_no_left_delimiter_backwards(self):
        self.assertSwapsBackwards("one, tw|o|", "|t|wo, one")

    def test_swap_no_left_delimiter_space(self):
        self.assertSwaps(" |t|wo, one", " one, tw|o|")

    def test_swap_no_left_delimiter_space_backwards(self):
        self.assertSwapsBackwards(" one, tw|o|", " |t|wo, one")

    def test_swap_no_left_delim_three_elements(self):
        self.assertSwaps("|t|wo, one, three", "one, tw|o|, three")

    def test_swap_no_left_delimiter_three_elements(self):
        self.assertSwapsBackwards("one, tw|o|, three", "|t|wo, one, three")

    def test_swap_no_left_three_elements(self):
        self.assertSwapsBackwards("one, two, thr|e|e", "one, |t|hree, two")

    def translate(self, str):
        l = []
        i=0
        cursor = -1
        for ch in str:
            if ch == '|':
                cursor = i-1 # in str "|a|rg" cursor is in col 0
            else:
                l.append(ch)
                i += 1
        l = ''.join(l)
        if (cursor== -1):
            return l
        else:
            return (l,cursor)

    def assertSwaps(self, input, expectedOutput):
        lst, col = self.translate(input)
        actual = SwapParams.Swap(lst,col)
        assert actual == self.translate(expectedOutput) 

    def assertSwapsBackwards(self, input, expectedOutput):
        lst, col = self.translate(input)
        actual = SwapParams.SwapBackwards(lst,col)
        assert actual == self.translate(expectedOutput) 

