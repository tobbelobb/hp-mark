#include <cmath>
#include <iostream>

#include <gsl/span_ext>

#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>   // waitKey
#include <opencv2/imgcodecs.hpp> // IMREAD_COLOR/IMREAD_UNCHANGED/IMREAD_GREYSCALE

auto main(int const argc, char **const argv) -> int {
  // Configure optional command line options.
  std::stringstream usage;
  usage << "Usage:\n" << *argv << " image\n";
  constexpr int MAX_ARGC{2};
  constexpr int MIN_ARGC{2};
  if (argc < MIN_ARGC or argc > MAX_ARGC) {
    std::cout << usage.str();
    return 0;
  }
  constexpr unsigned int NUM_MANDATORY_ARGS = 1;
  gsl::span<char *> const mandatoryArgs(&argv[1], NUM_MANDATORY_ARGS);
  auto *const imageFileName = gsl::at(mandatoryArgs, 0);

  cv::Mat const image = cv::imread(imageFileName, cv::IMREAD_COLOR);

  if (image.empty()) {
    std::cerr << "Could not read the image: " << imageFileName << '\n';
    return 1;
  }

  cv::namedWindow("Display image", cv::WINDOW_NORMAL);
  cv::resizeWindow("Display image", 300, 300);
  cv::imshow("Display image", image);
  // Wait for a keystroke in the window
  if (cv::waitKey(0) == 's') {
    cv::imwrite("image.png", image);
  }

  return 0;
}
