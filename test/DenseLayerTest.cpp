/*
 * Copyright (c) 2015 - 2023, Intel Corporation
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "gtest/gtest.h"
#include "gmock/gmock.h"
#include "geopm/Exception.hpp"
#include "geopm_test.hpp"

#include "DenseLayer.hpp"
#include "DenseLayerImp.hpp"
#include "TensorOneD.hpp"
#include "TensorTwoD.hpp"

#include "MockTensorMath.hpp"
#include "TensorOneDMatcher.hpp"
#include "TensorTwoDMatcher.hpp"

using geopm::TensorOneD;
using geopm::TensorTwoD;
using geopm::DenseLayer;
using geopm::DenseLayerImp;
using ::testing::Mock;
using ::testing::Return;
using ::testing::_;

class DenseLayerTest : public ::testing::Test
{
    protected:
        void SetUp() override;
};

void DenseLayerTest::SetUp()
{
}

TEST_F(DenseLayerTest, test_inference) {
    auto fake_math = std::make_shared<MockTensorMath>();

    TensorTwoD weights(
            std::vector<std::vector<double> >(
                {{1, 2, 3}, {4, 5, 6}}
                ),
            fake_math
            );

    TensorOneD biases(
            std::vector<double>(
                {7, 8}
                ),
            fake_math
            );

    DenseLayerImp layer(weights, biases);

    TensorOneD inp(
            std::vector<double>(
                {1, 2, 3}
                ),
            fake_math
            );

    TensorOneD tmp1(
            std::vector<double>(
                {3, 8, 9, 30}
                ),
	    fake_math
            );

    TensorOneD tmp2(
            std::vector<double>(
                {10, 8, -1}
                ),
	    fake_math
            );

    EXPECT_CALL(*fake_math,
                multiply(TensorTwoDEqualTo(weights),
                         TensorOneDEqualTo(inp)))
	    .WillOnce(Return(tmp1));
    EXPECT_CALL(*fake_math,
                add(TensorOneDEqualTo(biases),
                    TensorOneDEqualTo(tmp1)))
	    .WillOnce(Return(tmp2));

    EXPECT_EQ(3u, layer.get_input_dim());
    EXPECT_EQ(2u, layer.get_output_dim());

    TensorOneD out = layer.forward(inp);
}

TEST_F(DenseLayerTest, test_bad_dimensions) {
    auto fake_math = std::make_shared<MockTensorMath>();

    TensorTwoD weights(
            std::vector<std::vector<double> >(
                {{1, 2, 3}, {4, 5, 6}}
                ),
            fake_math
            );

    TensorOneD biases(
            std::vector<double>(
                {7, 8}
                ),
            fake_math
            );

    DenseLayerImp layer(weights, biases);

    TensorOneD inp(
            std::vector<double>(
                {1, 2, 3, 4}
                ),
            fake_math
            );

    GEOPM_EXPECT_THROW_MESSAGE(DenseLayerImp(TensorTwoD(), inp),
                               GEOPM_ERROR_INVALID,
                               "Empty array is invalid for neural network weights.");

    GEOPM_EXPECT_THROW_MESSAGE(DenseLayerImp(weights, inp),
                               GEOPM_ERROR_INVALID,
                               "Incompatible dimensions for weights and biases.");

    GEOPM_EXPECT_THROW_MESSAGE(layer.forward(inp),
                               GEOPM_ERROR_INVALID,
                               "Input vector dimension is incompatible with network");
}
