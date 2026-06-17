---
name: test-strategy
description: Use when adding, updating, selecting, or running tests for a change.
---


# Test Strategy Skill

## Purpose

Choose practical tests that increase confidence without excessive test cost.

## Test Selection

Prefer the narrowest test that proves behavior:

1. Unit test for pure logic and domain rules.
2. Integration test for persistence, transactions, framework wiring, or external boundaries.
3. API/controller test for request/response behavior.
4. End-to-end test only when behavior cannot be verified reliably at lower levels.

## Required Test Thinking

For every change, consider happy path, invalid input, permission or state restrictions, boundary values, and regression case if fixing a bug.

## When Tests Cannot Be Run

Report which checks could not be run, why, and what command should be run by a human/CI.

## Output

- tests added/updated
- commands run
- results
