using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Sample
{
    /// <summary>
    /// A generic repository interface used to exercise the theme.
    /// </summary>
    /// <typeparam name="T">The entity type.</typeparam>
    public interface IRepository<T> where T : class, new()
    {
        T GetById(int id);
        Task AddAsync(T item);
        IEnumerable<T> All { get; }
    }

    public enum Status
    {
        Pending,
        Active,
        Disabled = 5
    }

    public struct Point
    {
        public int X { get; }
        public int Y { get; }

        public Point(int x, int y)
        {
            X = x;
            Y = y;
        }

        public readonly double Distance => Math.Sqrt(X * X + Y * Y);
    }

    public class Repository<T> : IRepository<T> where T : class, new()
    {
        private readonly List<T> _items = new List<T>();
        private const int Capacity = 1000;

        public static Repository<T> Instance { get; } = new Repository<T>();

        public IEnumerable<T> All => _items.AsEnumerable();

        public bool IsEmpty
        {
            get => _items.Count == 0;
            private set { }
        }

        public T GetById(int id)
        {
            if (id < 0)
            {
                throw new ArgumentOutOfRangeException(nameof(id));
            }
            else if (id == 0)
            {
                return new T();
            }

            return id < _items.Count ? _items[id] : default;
        }

        public async Task AddAsync(T item)
        {
            if (item == null) return;

            switch (_items.Count)
            {
                case 0:
                    Console.WriteLine("First item added.");
                    break;
                case 10 when Capacity > 20:
                    Console.WriteLine("Half full.");
                    goto default;
                default:
                    Console.WriteLine($"Adding item #{_items.Count + 1}");
                    break;
            }

            try
            {
                _items.Add(item);
                await Task.Delay(10);
            }
            catch (Exception ex) when (ex is InvalidOperationException || ex is TaskCanceledException)
            {
                Console.Error.WriteLine(ex.Message);
            }
            finally
            {
                Console.WriteLine("Done.");
            }
        }
    }

    public record Person(string Name, int Age)
    {
        public Status State { get; init; } = Status.Active;

        public string Greet(string greeting = "Hello") =>
            $"{greeting}, {Name}! You are {Age} years old.";
    }

    public static class Program
    {
        public static async Task Main(string[] args)
        {
            var people = new List<Person>
            {
                new("Alice", 30),
                new("Bob", 25),
                new("Carol", 40)
            };

            var adult = people.FirstOrDefault(p => p.Age >= 30);
            var names = from p in people
                        where p.Age > 20
                        select p.Name;

            Console.WriteLine($"Found: {adult?.Name ?? "nobody"}");

            for (int i = 0; i < 3; i++)
            {
                foreach (var name in names)
                {
                    Console.WriteLine($"{i}: {name}");
                }
            }

            int count = 0;
            while (count < 2)
            {
                count++;
                do
                {
                    count++;
                } while (count < 1);
            }

            Point p = new Point(3, 4);
            double dist = p.Distance;

#if DEBUG
            Console.WriteLine("Debug build: {0}", dist);
#else
            Console.WriteLine($"{dist:F2}");
#endif

            Repository<Person> repo = Repository<Person>.Instance;
            await repo.AddAsync(new Person("Dave", 33));

            Func<int, int> square = x => x * x;
            Console.WriteLine(square(5));

            var dict = new Dictionary<string, int> { ["one"] = 1, ["two"] = 2 };
            Console.WriteLine(dict.TryGetValue("two", out int two) ? two : -1);

            unsafe
            {
                int value = 42;
                int* pointer = &value;
                Console.WriteLine(*pointer);
            }
        }
    }
}