extern crate sample_godot_rust_app;
extern crate speculate;

use speculate::speculate;
use sample_godot_rust_app::add;

speculate! {
    describe "sample test" {
        it "can add stuff" {
            assert_eq!(1, add(0, 1));
            assert_eq!(2, add(1, 1));
        }
    }
}