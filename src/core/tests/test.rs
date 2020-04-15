use speculate::speculate;
use core::add;

speculate! {
    describe "sample test" {
        it "can add stuff" {
            assert_eq!(1, add(0, 1));
            assert_eq!(2, add(1, 1));
        }
    }
}