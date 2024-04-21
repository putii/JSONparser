// #include "Functor.hpp"
#include <functional>
#include <gtest/gtest.h>
#include <iostream>
#include <ranges>

/*template <typename Input>
class A  {
public:
  A(const Input& t_) : t(t_) {}
  ~A() = default;
  void print() const { std::cout << t << std::endl; }
private:
  Input t;
  friend class FunctorA;
};

class FunctorA : public Functor<std::string, int, A>
{
public:
  A<int> fmap(const std::function<int(std::string)>& f, const A<std::string>& a) const
override
  {
    return A{f(a.t)};
  }
  ~FunctorA() override {}
};

TEST(Functor, FunctorReconnaissanceInForce) {
  A<std::string> a{"123"};
  auto converter =
    [](const std::string& s){ return std::stoi(s); };
  FunctorA().fmap(converter, a).print();
}*/

//////////////////////////////////////////////////

// https://bartoszmilewski.com/2015/01/20/functors/#:~:text=of%20fmap.-,The%20List%20Functor,-To%20get%20some
/*template<class A, class B>
std::vector<B> fmap(std::function<B(A)> f, std::vector<A> v) {
  std::vector<B> w;
  std::transform(std::begin(v), std::end(v), std::back_inserter(w), f);
  return w;
}

TEST(b_milewski, TheListFunctor) {
  std::vector<int> v{ 1, 2, 3, 4 };
  auto w = fmap<int, int>([](int i) { return i * i; }, v);
  std::copy(std::begin(w), std::end(w), std::ostream_iterator<int>(std::cout, ", "));
}*/

///////////////////////////////////////////////
/**
 * Here goes B. Milewski inspired Functor
 */

/*
template<typename A>
class Functor {
public:
  Functor(const A& value_) : value(value_) {}
  void print() const { std::cout << value << '\n'; }
  // private: // do i really need the value to be private ?
  A value;
};

*/
/*
 * Do i really need template<typename> typename Functor parameter here:
 * template<typename A, typename B, template<typename> typename Functor>
 * or maybe just
 * template<typename A, typename B>
 * ???
 *//*

template<typename A, typename B, template<typename> typename Functor>
Functor<B> fmap(const std::function<B(A)>& f, const Functor<A>& functorA) {
  return Functor<B>{ f(functorA.value) };
}


TEST(FunctorWithOneTemplateParam, SimpleExamples) {
  Functor functorStr{ std::string("123") };
  functorStr.print();

  // Can I have reference to Functors of diff template parameters?
  Functor<std::string>& functorRef = functorStr;
  functorRef.print();

  const auto converterTransformer = [](const std::string& s) {
    return std::stoi(s) - 121;
  };
  */
/* fmap(converter, functorStr).print(); // cannot deduce proper string type - gets stuck
 * on std::string& vs const std::string& *//*

  auto functorInt = fmap<std::string, int>(converterTransformer, functorStr);
  functorInt.print();
  // functorRef = functorInt; // will not compile - types do not match
  auto floatCircleArea = [](int i) {
    return static_cast<float>(3.14) * static_cast<float>(i) * static_cast<float>(i);
  };
  auto functorFloat = fmap<int, float>(floatCircleArea, functorInt);
  functorFloat.print();
}
*/

///////////////////////////////////////////////
/**
 * Here I want to implement another approach to C++ Functor implementation
 * I would like different Functor types share the same interface
 * So I could have a reference to different template classes of Functor
 * I am not sure whether I will need it or not,
 * but for now let's just pick up this gauntlet
 * Maybe call my concrete template generic classes TypedFunctor or GenericFunctor ?
 */


class Functor { // glossary: interface - if; interfaced - ifed
public:
  virtual void print() const = 0;
  // TODO How to tackle that ?
  /*
   * what if I stored value in some (smart) pointer,
   * getValue would get the pointer to this value, casted it to void*
   * and then the getValue() caller would need to recast it back
   * to the valid type?
   */
  // virtual void* getValue() = 0; // TODO Implement
  virtual ~Functor() = 0;
};

/**
 * AFAIUnderstand, all GenericFunctor template classes will share
 * Functor interface, allowing to use Functor as a reference
 * for different GenericFunctor template classes
 * @tparam A type of value stored by GenericFunctor
 */
template<typename A>
class GenericFunctor : public Functor {
public:
  GenericFunctor(const A& value_) : value(std::make_unique<A>(value_)) {}
  void print() const override { std::cout << value << '\n'; }
  // void* getValue() override {}
  // private: // do i really need the value to be private ?
  std::unique_ptr<A> value;
  ~GenericFunctor() override = default;
};

template<typename A, typename B>
GenericFunctor<B> fmap(const std::function<B(A)>& f, const GenericFunctor<A>& functorA) {
  return GenericFunctor<B>{ f(functorA.value) };
}

TEST(FunctorWithOneTemplateParam, AnotherApproach) {
  // TODO: Before implementing start with writing tests focusing on desired programmer
  // interface
  GenericFunctor genericFunctor{ std::string("123") };
  Functor& functorRef = genericFunctor;
}