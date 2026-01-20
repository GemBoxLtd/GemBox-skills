#!/usr/bin/env python3
"""Factorial calculator supporting values up to 50!"""

import sys


def factorial(n: int) -> int:
    """Calculate factorial of n (supports n up to 50)."""
    if not isinstance(n, int) or n < 0:
        raise ValueError("n must be a non-negative integer")
    if n > 50:
        raise ValueError("n must be <= 50")

    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def run_tests():
    """Run simple tests for factorial function."""
    test_cases = [
        (0, 1),
        (1, 1),
        (5, 120),
        (25, 15511210043330985984000000),
        (50, 30414093201713378043612608166064768844377641568960512000000000000),
    ]

    print("Running tests:")
    print("-" * 60)

    all_passed = True
    for n, expected in test_cases:
        result = factorial(n)
        passed = result == expected
        status = "PASS" if passed else "FAIL"
        print(f"{n}! = {result}")
        print(f"   Expected: {expected}")
        print(f"   Status: {status}")
        if not passed:
            all_passed = False

    print("-" * 60)
    print(f"All tests passed: {all_passed}")
    return all_passed


def main():
    if len(sys.argv) > 1:
        try:
            n = int(sys.argv[1])
            result = factorial(n)
            print(f"{n}! = {result}")
        except ValueError as e:
            print(f"Error: {e}")
            sys.exit(1)
    else:
        print(f"Usage: {sys.argv[0]} <n>")
        print("       Calculate factorial of n (0 <= n <= 50)")
        print()
        run_tests()


if __name__ == "__main__":
    main()
