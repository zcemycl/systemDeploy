#include <math.h>
#include "random.h"
// #include <gtest/gtest.h>
// #include <gmock/gmock.h>
 
// class Turtle
// {
//     public:
//         virtual ~Turtle() {}
//         virtual void PenUp() = 0;
//         virtual void PenDown() = 0;
//         virtual void Forward(int distance) = 0;
//         virtual void Turn(int degrees) = 0;
//         virtual void GoTo(int x, int y) = 0;
//         virtual int GetX() const = 0;
//         virtual int GetY() const = 0;
// };

// class Painter
// {
//     Turtle *turtle;

//     public:
//         Painter(Turtle *turtle) : turtle(turtle) {}
//         bool DrawCircle(int, int, int)
//         {
//             turtle->PenDown();
//             return true;
//         }
// };

// class MockTurtle : public Turtle
// {
//     public:
//         MOCK_METHOD0(PenUp, void());
//         MOCK_METHOD0(PenDown, void());
//         MOCK_METHOD1(Forward, void(int distance));
//         MOCK_METHOD1(Turn, void(int degrees));
//         MOCK_METHOD2(GoTo, void(int x, int y));
//         MOCK_CONST_METHOD0(GetX, int());
//         MOCK_CONST_METHOD0(GetY, int());
// };

double squareRoot(const double a) {
    double b = sqrt(a);
    if(b != b) { // nan check
        return -1.0;
    }else{
        return sqrt(a);
    }
}