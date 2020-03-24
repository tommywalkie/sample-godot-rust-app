extern crate root_node;
extern crate speculate;

use speculate::speculate;
use root_node::math;

speculate! {
    describe "sample test" {
        it "can add stuff" {
            assert_eq!(1, math::add(0, 1));
            assert_eq!(2, math::add(1, 1));
        }
    }
}