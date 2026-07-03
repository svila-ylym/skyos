#!/usr/bin/env python3
"""SkyCalc: minimal interactive calculator for SkyOS SAPP demos."""

import ast
import operator


OPS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.FloorDiv: operator.floordiv,
    ast.Mod: operator.mod,
    ast.Pow: operator.pow,
    ast.USub: operator.neg,
    ast.UAdd: operator.pos,
}


def evaluate(expr):
    tree = ast.parse(expr, mode="eval")
    return eval_node(tree.body)


def eval_node(node):
    if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return node.value
    if isinstance(node, ast.BinOp) and type(node.op) in OPS:
        return OPS[type(node.op)](eval_node(node.left), eval_node(node.right))
    if isinstance(node, ast.UnaryOp) and type(node.op) in OPS:
        return OPS[type(node.op)](eval_node(node.operand))
    raise ValueError("only numbers and + - * / // % ** parentheses are supported")


def main():
    history = []
    print("SkyCalc 1.0 - type help, history, or quit")
    while True:
        try:
            line = input("calc> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            return
        if not line:
            continue
        command = line.lower()
        if command in {"quit", "exit", "q"}:
            return
        if command == "help":
            print("Examples: 1 + 2 * 3, (8 / 2) ** 3, 10 % 3")
            print("Commands: help, history, clear, quit")
            continue
        if command == "history":
            for idx, item in enumerate(history, 1):
                print(f"{idx}: {item}")
            continue
        if command == "clear":
            history.clear()
            print("history cleared")
            continue
        try:
            result = evaluate(line)
        except Exception as exc:
            print(f"error: {exc}")
            continue
        record = f"{line} = {result}"
        history.append(record)
        print(result)


if __name__ == "__main__":
    main()
