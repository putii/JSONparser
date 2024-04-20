#ifndef JSONPARSER_FUNCTOR_HPP
#define JSONPARSER_FUNCTOR_HPP

#include <functional>


template<typename A, typename B, template <typename> typename C>
struct Functor {
  virtual C<B> fmap(const std::function<B(A)>&, const C<A>&) const = 0;
  virtual ~Functor() = default;
};


#endif // JSONPARSER_FUNCTOR_HPP
