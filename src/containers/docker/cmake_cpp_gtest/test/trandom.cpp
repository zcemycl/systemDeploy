#include "random.h"
#include <gtest/gtest.h>
#include <gmock/gmock.h>

using ::testing::AtLeast;   
 
TEST(SquareRootTest, PositiveNos) { 
    ASSERT_EQ(6, squareRoot(36.0));
    ASSERT_EQ(18.0, squareRoot(324.0));
    ASSERT_EQ(25.4, squareRoot(645.16));
    ASSERT_EQ(0, squareRoot(0.0));
}
 
TEST(SquareRootTest, NegativeNos) {
    ASSERT_EQ(-1.0, squareRoot(-15.0));
    ASSERT_EQ(-1.0, squareRoot(-0.2));
}

// TEST(PainterTest, CanDrawSomething)
// {
//     MockTurtle turtle;             // #2

//     EXPECT_CALL(turtle, PenDown()) // #3
//         .Times(AtLeast(1));

//     Painter painter(&turtle); // #4

//     EXPECT_TRUE(painter.DrawCircle(0, 0, 10));
// } // #5
 
int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}