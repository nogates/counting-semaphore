# counting-semaphore

## What is it?

Counting Semaphore is a simple tool to quantify pixel number based on image color channel for scientific purpose.

It uses rmagick to extract the RGB channels from the images and then, counts the number of non black pixels on each image. 

By default, a pixel is considered to be a non black if its strengh is 25 or above (using the RGB color namespace), but it can be configured in each run.

## How to use it

 - Clone or download the repo
 - Run `bundle install` or install rmagick manually.
 - Run `bin/counting-semaphore <Folder> <tolerance: optional>`
 - A csv file will be generated with the information of each image.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See [LICENSE](https://raw.githubusercontent.com/nogates/counting-semaphore/master/LICENSE).

