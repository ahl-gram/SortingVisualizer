class Program
{
    const int CUBE_SIZE = 8;

    static int[] CubeSort(int[] arr, int n)
    {
        // Divide the array into cubes of size CUBE_SIZE
        for (int i = 0; i < n; i += CUBE_SIZE)
        {
            Array.Sort(arr, i, Math.Min(CUBE_SIZE, n - i));
        }

        // Merge the cubes
        int[] temp = new int[n];
        for (int i = 0; i < n; i += CUBE_SIZE)
        {
            Array.Copy(arr, i, temp, i, Math.Min(CUBE_SIZE, n - i));
            Array.Sort(temp, i, Math.Min(CUBE_SIZE, n - i));
            Array.Copy(temp, i, arr, i, Math.Min(CUBE_SIZE, n - i));
        }

        // Merge the cubes back together
        for (int i = 0; i < n; i += CUBE_SIZE)
        {
            Array.Copy(arr, i, temp, i, Math.Min(CUBE_SIZE, n - i));
            Array.Sort(temp, i, Math.Min(CUBE_SIZE, n - i));
            Array.Copy(temp, i, arr, i, Math.Min(CUBE_SIZE, n - i));
        }

        return arr;
    }
}