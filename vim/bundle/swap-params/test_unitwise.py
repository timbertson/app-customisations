from SwapParams import findFirst, RightwardDirection

class TestList(object):
    def verifyFindFirstReturns(self, eToFind, stringToSearch, expected):
        assert findFirst(lambda x: eToFind == x, iter(stringToSearch), RightwardDirection()) == expected


    def test_findFirst(self):
        self.verifyFindFirstReturns('d', "abcd", 3)
        self.verifyFindFirstReturns('c', "a", -1)
        self.verifyFindFirstReturns('s', "(asd)s", 5)
        self.verifyFindFirstReturns('s', "()()s", 4)
        self.verifyFindFirstReturns(']', '[]]', 2)
    
