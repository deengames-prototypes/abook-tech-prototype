package deengames.math;

class DiscreteRandom
{
    public static function pick<T>(a:Array<T>):T
    {
        var index = Math.floor(Math.random() * a.length);
        return a[index];
    }
}