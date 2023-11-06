#!/usr/bin/env nu

def test-time [] {
  use std testing run-tests;

  run-tests --module time
}
