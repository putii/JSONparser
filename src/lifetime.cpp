#include <source_location>
#include <cstdio>
#include <optional>

void print(const std::source_location& location =
std::source_location::current()) noexcept {
  std::puts(location.function_name());
}


struct Lifetime {
    Lifetime(int) noexcept { print(); }
    Lifetime() noexcept { print(); }
    Lifetime(Lifetime&&) noexcept { print(); }
    Lifetime(const Lifetime&) noexcept { print(); }
    ~Lifetime() noexcept { print(); }
    Lifetime& operator=(const Lifetime&) noexcept {
      print();
      return *this;
    }

    Lifetime& operator=(Lifetime&&) noexcept {
      print();
      return *this;
    }
};

int main() {
  std::optional<Lifetime> lifetimeOptional = std::make_optional<Lifetime>();
  return 0;
}