using Godot;
using System;
namespace Gunmetal.Util
{
    public partial class Physics : Node
    {
        public override void _Ready(){}
        public int PlayerHitbox = 1; 
        public int PlayerHurtbox = 2;
        public int EnemyHitbox = 3; 
        public int EnemyHurtbox = 4; 
        public int Floor = 5;
        public int Wall =  6;
        public int Projectile = 7;
    }
}