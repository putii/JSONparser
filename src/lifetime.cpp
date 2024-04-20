#include <cstdio>
#include <optional>
#include <source_location>


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

  return 0;
}