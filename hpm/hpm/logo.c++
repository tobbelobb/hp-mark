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

  cv::Mat logo{300, 300, CV_8UC3, cv::Vec3b{255, 255, 255}};
  cv::Point const center =
      cv::Point(logo.size().width / 2, logo.size().height / 2);
  double const outerRadius = 150.0;
  double const innerRadius = 100.0;
  std::cout << logo.rows << " " << logo.cols << '\n';
  std::cout << center.y << " " << center.x << '\n';

  // for (int r = 0; r < logo.rows; r++) {
  //  for (int c = 0; c < logo.cols; c++) {
  //    double const dist = sqrt((c - center.x) * (c - center.x) +
  //                             (r - center.y) * (r - center.y));
  //    if (dist < outerRadius and dist > innerRadius) {
  //      // std::cout << "r: " << r << " c: " << c << std::endl;
  //      logo.at<cv::Vec3b>(r, c) = cv::Vec3b(dist, 0, 0);
  //    } else {
  //      // Point is outside circle
  //    }
  //  }
  //}
  //
  //
  // for (double radius = innerRadius; radius < outerRadius; radius += 1) {
  //  for (double theta = 0.0; theta < 2 * CV_PI;
  //       theta += 1.0 / (2 * radius * CV_PI)) {
  //    int const row = center.y + radius * cos(theta);
  //    int const col = center.x + radius * sin(theta);
  //    int const zero_to_255 = (theta * 256) / (2 * CV_PI);
  //    int const zero_to_510 = (theta * 2 * 256) / (2 * CV_PI);
  //    int const zero_to_765 = (theta * 3 * 256) / (2 * CV_PI);
  //    cv::Vec3b bgr{static_cast<unsigned char>((zero_to_765) % 256),
  //                  static_cast<unsigned char>(255 - (zero_to_765 % 256)),
  //                  static_cast<unsigned char>(0)};
  //    if (zero_to_765 >= 256 and zero_to_765 < 512) {
  //      bgr = cv::Vec3b{static_cast<unsigned char>(0),
  //                      static_cast<unsigned char>((zero_to_765) % 256),
  //                      static_cast<unsigned char>(255 - (zero_to_765 %
  //                      256))};
  //    }
  //    if (zero_to_765 >= 512) {
  //      bgr = cv::Vec3b{static_cast<unsigned char>(255 - (zero_to_765 % 256)),
  //                      static_cast<unsigned char>(0),
  //                      static_cast<unsigned char>((zero_to_765) % 256)};
  //    }
  //    logo.at<cv::Vec3b>(row, col) = bgr;
  //  }
  //}
  for (double radius = innerRadius; radius < outerRadius; radius += 1) {
    for (double theta = 0.0; theta < 2 * CV_PI;
         theta += 1.0 / (2 * radius * CV_PI)) {
      int const row = center.y + radius * cos(theta);
      int const col = center.x + radius * sin(theta);
      logo.at<cv::Vec3b>(row, col) =
          cv::Vec3b(static_cast<int>(theta * 255.0 / (2 * CV_PI)),
                    255.0 - (theta * 255.0 / (2 * CV_PI)), 0);
    }
  }
  for (double radius = 0; radius < innerRadius - 2; radius += 1) {
    for (double theta = 0.0; theta < 2 * CV_PI;
         theta += 1.0 / (2 * radius * CV_PI)) {
      int const row = center.y + radius * cos(theta);
      int const col = center.x + radius * sin(theta);
      logo.at<cv::Vec3b>(row, col) = cv::Vec3b(0, 0, 255);
    }
  }

  cv::namedWindow("Display image", cv::WINDOW_NORMAL);
  cv::resizeWindow("Display image", 300, 300);
  cv::imshow("Display image", logo);
  // Wait for a keystroke in the window
  if (cv::waitKey(0) == 's') {
    cv::imwrite("logo.png", logo);
  }

  return 0;
}
