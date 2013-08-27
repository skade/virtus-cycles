# Virtus::Cycles

A gem that detects possible cycles in virtus class graphs.

Also includes a very rough implementation for walking virtus graphs.

## Warning

This is one of my train hacks. Possible to be abandoned soon.

## Installation

Currently git only:

```
git clone git@github.com:skade/virtus-cycles.git
```

or

```
gem 'virtus-cycles', :git => "git@github.com:skade/virtus-cycles.git"
```

## Usage

Currently, have a look at `cross.rb` for an example for marking attributes to be possibly cyclic.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
