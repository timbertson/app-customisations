leftBrackets = ['[', '(']
rightBrackets = [']', ')']

class Direction(object):
    def isOpenBracket(self, char):
        return char in self.openingBrackets

    def isCloseBracket(self, char):
        return char in self.closingBrackets

    def isBackward(self):
        return self.openingBrackets is rightBrackets

    def isForward(self):
        return not self.isBackward()
    

class RightwardDirection(Direction):
    openingBrackets = leftBrackets
    closingBrackets = rightBrackets
    def opposite(self):
        return LeftwardDirection()

class LeftwardDirection(Direction):
    openingBrackets = rightBrackets
    closingBrackets = leftBrackets
    def opposite(self):
        return RightwardDirection()


def findFirst(predicate, input, direction=None, eolIsDelimiter=False):
    def find(pos=0):
        try:
            head = input.next()
            if predicate(head):
                return pos
            elif direction and direction.isOpenBracket(head):
                charsInsideBrackets = \
                    findFirst(direction.isCloseBracket, input, direction)
                return find(pos + charsInsideBrackets+1 + 1)
            else:
                return find(pos+1)
        except:
            if eolIsDelimiter:
                return pos
            return -1
    return find()


def SwapParams(direction, line, col):

    def areThereNoEnclosinBrackets():
        rightBracketIndex = findFirst(rightBrackets.__contains__,
                                 iter(line[col:]),
                                 RightwardDirection()
        ) 
        return rightBracketIndex == -1

    noEncloseBrackets = areThereNoEnclosinBrackets()

    def findTheSeparatorBeforeTheLeftParam():
        prefixRev = reversed(line[:col+1])
        toTheLeft = 0
        if line[col] in leftBrackets:
            prefixRev.next()
            toTheLeft += 1

        def findNextLeftSeparator(separators=leftBrackets+[',']):
            return findFirst(separators.__contains__,
                             prefixRev,
                             LeftwardDirection(),
                             eolIsDelimiter=True
            ) 

        if direction.isForward() and noEncloseBrackets:
            toTheLeft += findNextLeftSeparator(separators=[' '])
        else:
            toTheLeft += findNextLeftSeparator()

        if direction.isBackward():
            if noEncloseBrackets:
                toTheLeft += 1 + findNextLeftSeparator(separators=[' '])
            else:
                toTheLeft += 1 + findNextLeftSeparator()

        return col - toTheLeft + 1

    start = findTheSeparatorBeforeTheLeftParam()
    nonwhitespace = lambda x: x not in (' ', '\t')
    input = iter(line[start:])
    param1start = start + findFirst(nonwhitespace, input)
    param1end = param1start + findFirst(
                                    lambda x: x == ',', 
                                    iter(line[param1start:]), 
                                    RightwardDirection()
    ) - 1
    param2start = param1end + 2 + findFirst(nonwhitespace, iter(line[param1end+2:]))
    rightSeparators = rightBrackets + [',']
    if noEncloseBrackets:
        rightSeparators = [' ', ',']
    param2end = param2start - 1 + findFirst(
                                    rightSeparators.__contains__, 
                                    iter(line[param2start:]), 
                                    RightwardDirection(), 
                                    eolIsDelimiter=True)

    if direction.isForward():
        cursorPos = param2end
    else:
        cursorPos = param1start

    return (line[:param1start] 
          + line[param2start: param2end+1] 
          + line[param1end+1: param2start]
          + line[param1start: param1end+1]
          + line[param2end+1:],
          cursorPos
    )


def Swap(line, col):
    return SwapParams(RightwardDirection(), line, col)

def SwapBackwards(line, col):
    return SwapParams(LeftwardDirection(), line, col)
    
if __name__ == '__main__':
    import vim
    (row, col) = vim.current.window.cursor
    line = vim.current.buffer[row-1]
    try:
        (line, newCol) = Swap(line,col)
        vim.current.buffer[row-1] = line
        vim.current.window.cursor = (row, newCol)
    except Exception, e:
        print e
