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

  cv::Mat topLeftCorner{image, cv::Rect{0, 0, 5, 5}};
  // std::cout << topLeftCorner << std::endl;

  cv::Mat redImage{924, 1230, CV_8UC3, cv::Vec3b{0, 0, 255}};
  cv::Point const center =
      cv::Point(redImage.size().width / 2, redImage.size().height / 2);
  double const outerRadius = 150.0;
  double const innerRadius = 100.0;
  std::cout << redImage.rows << " " << redImage.cols << '\n';
  std::cout << center.x << " " << center.y << '\n';

  for (int r = 0; r < redImage.rows; r++) {
    for (int c = 0; c < redImage.cols; c++) {
      double const dist = sqrt((c - center.x) * (c - center.x) +
                               (r - center.y) * (r - center.y));
      if (dist < outerRadius and dist > innerRadius) {
        // std::cout << "r: " << r << " c: " << c << std::endl;
        redImage.at<cv::Vec3b>(r, c) = cv::Vec3b(dist, 0, 0);
      } else {
        // Point is outside circle
      }
    }
  }

  cv::namedWindow("Display image", cv::WINDOW_NORMAL);
  cv::resizeWindow("Display image", 1230, 924);
  cv::imshow("Display image", redImage);
  // Wait for a keystroke in the window
  if (cv::waitKey(0) == 's') {
    cv::imwrite("starry_night.png", image);
  }

  return 0;
}
