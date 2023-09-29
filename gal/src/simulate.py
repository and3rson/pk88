from collections import namedtuple

CODE = """
Q0.R   = /Q0 * /Q1
Q1.R   =  Q0 + /Q1
TMCK.R = /Q0 * /Q1 * /TMCK + /Q0 *  Q1 *  TMCK +  Q0 * Q1 * TMCK
"""

GRAY = "\033[90m"
RESET = "\033[0m"
BOLD_GREEN = "\033[1;32m"
# ]]]]]]

equations = {}
for equation in CODE.splitlines():
    equation = equation.strip()
    if not equation:
        continue
    left, right = map(str.strip, equation.split("="))
    additions = [
        list(map(str.strip, addition.split("*")))
        for addition in list(map(str.strip, right.split("+")))
    ]
    equations[left.partition(".")[0]] = additions


def print_bit(value):
    return f"{BOLD_GREEN}HIGH    {RESET}" if value else f"{GRAY}LOW     {RESET}"


def tick(state, equations):
    return {key: calculate(equations[key], state) for key in state}


def calculate(equation, state):
    add_result = False
    for addition in equation:
        mul_result = True
        for multiplier in addition:
            mul_value = state[multiplier.removeprefix("/")]
            if multiplier.startswith("/"):
                mul_value = not mul_value
            mul_result *= mul_value
        add_result += mul_result
    return add_result


print("    " + "".join([name.ljust(8) for name in equations.keys()]))

state = {key: False for key in equations.keys()}
for i in range(24):
    state = tick(state, equations)
    print(str(i + 1).rjust(2) + "  ", end="")
    for key in state:
        print(print_bit(state[key]), end="")
    print()
