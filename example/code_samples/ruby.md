!SLIDE

## Ruby

```ruby
class Fixnum

  def ounces
    # vanity
    self
  end

  def cup
    # conversion to ounces
    self * 16
  end
end
```

!SLIDE execute

# Executable Ruby

If you install the [parade-liveruby](https://github.com/burtlo/parade-liveruby)
gem, you can have ruby code be executable as well.

```ruby
[1, 2, 3].map { |n| n*7 }
```
