using Godot;
using System;

namespace Gunmetal.Util
{
public partial class Maths : Node
    {
        //constant values
        public float Gravity = 1000f;
        public override void _Ready(){}
        public double Pyth(double sideA, double sideB)
        {
            // Calculate the square of sideA and sideB
            double sideASquared = sideA * sideA;
            double sideBSquared = sideB * sideB;

            // Calculate the sum of the squares
            double sumOfSquares = sideASquared + sideBSquared;

            // Calculate the square root of the sum of squares to get the hypotenuse
            double hypotenuse = Math.Sqrt(sumOfSquares);

            return hypotenuse;
        }
    }
}
