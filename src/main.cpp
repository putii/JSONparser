#include <iostream>
#include <ranges>
#include <vector>

int main() {
  std::vector<int> vec1{ 1, 2, 3, 4 };
  std::vector<int> vec2{ 5, 6, 7, 8 };
  for (const auto& [val1, val2] : std::views::zip(vec1, vec2)) {
    std::cout << val1 << " " << val2 << '\n';
  }

  return 0;
}
