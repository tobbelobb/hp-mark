#include <cmath>
#include <iostream>

#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>   // waitKey
#include <opencv2/imgcodecs.hpp> // IMREAD_COLOR/IMREAD_UNCHANGED/IMREAD_GREYSCALE

auto main(int const argc, char **const argv) -> int {
  auto constexpr rows{600};
  auto constexpr cols{600};
  cv::Vec3b const background{255, 255, 255};

  // Matrices use rows-cols, Points use x-y
  cv::Point const center{cv::Point(cols / 2, rows / 2)};
  auto constexpr outerRadius{std::min(rows, cols) / 2};
  auto constexpr innerRadius{std::min(rows, cols) / 3};

  cv::Mat logo{rows, cols, CV_8UC3, background};
  for (auto radius{innerRadius}; radius < outerRadius; radius += 1) {
    for (auto theta{0.0}; theta < 2.0 * CV_PI;
         theta += 1.0 / (2.0 * radius * CV_PI)) {
      auto const row{center.y + radius * cos(theta)};
      auto const col{center.x + radius * sin(theta)};

      // Create a gradient effect from green to blue
      logo.at<cv::Vec3b>(row, col) =
          cv::Vec3b(theta * 255.0 / (2.0 * CV_PI),
                    255.0 - (theta * 255.0 / (2.0 * CV_PI)), 0);
    }
  }

  // The innerRadius - 2.0 leaves a 2 pixels wide circle of background
  // color between gradient circle band and colored circle in center
  for (auto radius{0.0d}; radius < innerRadius - 2.0; radius += 1.0) {
    for (auto theta{0.0d}; theta < 2.0 * CV_PI;
         theta += 1.0 / (2.0 * radius * CV_PI)) {
      auto const row = center.y + radius * cos(theta);
      auto const col = center.x + radius * sin(theta);

      // Fill with red
      logo.at<cv::Vec3b>(row, col) = cv::Vec3b(0, 0, 255);
    }
  }

  cv::namedWindow("Display image", cv::WINDOW_NORMAL);
  cv::resizeWindow("Display image", rows, cols);
  cv::imshow("Display image", logo);
  // Wait for a keystroke in the window
  // Save with s
  // Quit with any other keystroke
  if (cv::waitKey(0) == 's') {
    cv::imwrite("logo.png", logo);
  }

  return 0;
}
