/* ============================================================================
* Copyright (c) 2009-2016 BlueQuartz Software, LLC
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* Redistributions of source code must retain the above copyright notice, this
* list of conditions and the following disclaimer.
*
* Redistributions in binary form must reproduce the above copyright notice, this
* list of conditions and the following disclaimer in the documentation and/or
* other materials provided with the distribution.
*
* Neither the name of BlueQuartz Software, the US Air Force, nor the names of its
* contributors may be used to endorse or promote products derived from this software
* without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
* USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* The code contained herein was partially funded by the followig contracts:
*    United States Air Force Prime Contract FA8650-07-D-5800
*    United States Air Force Prime Contract FA8650-10-D-5210
*    United States Prime Contract Navy N00173-07-C-2068
*
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

#pragma once


#include "EbsdLib/Utilities/ModifiedLambertProjection.h"

class ProjectionConversions
{

public:
  ProjectionConversions() = default;
  ~ProjectionConversions() = default;

  template <typename T>
  std::vector<float> convertLambertSquareData(const std::vector<T>& lsData, size_t dim, int32_t projType, size_t zValue = 0,
                                              ModifiedLambertProjection::Square square = ModifiedLambertProjection::Square::NorthSquare) const
  {
    ModifiedLambertProjection::Pointer lambertProjection = ModifiedLambertProjection::New();
    lambertProjection->initializeSquares(static_cast<int32_t>(dim), 1.0f);

    for(size_t y = 0; y < dim; y++)
    {
      for(size_t x = 0; x < dim; x++)
      {
        size_t index = dim * dim * zValue + dim * y + x;
        int32_t projIdx = static_cast<int32_t>(dim * y + x);
        lambertProjection->setValue(square, projIdx, static_cast<double>(lsData.at(index)));
      }
    }

    std::vector<float> stereoProj;
    if(projType == 0)
    {
      EbsdLib::DoubleArrayType::Pointer data = lambertProjection->createStereographicProjection(static_cast<int32_t>(dim));
      stereoProj.resize(data->getSize());
      for(size_t i = 0; i < data->getSize(); i++)
      {
        stereoProj[i] = (*data)[i];
      }
    }
    else
    {
      stereoProj = lambertProjection->createCircularProjection(static_cast<int32_t>(dim));
    }
    return stereoProj;
  }

public:
  ProjectionConversions(const ProjectionConversions&) = delete;            // Copy Constructor Not Implemented
  ProjectionConversions(ProjectionConversions&&) = delete;                 // Move Constructor Not Implemented
  ProjectionConversions& operator=(const ProjectionConversions&) = delete; // Copy Assignment Not Implemented
  ProjectionConversions& operator=(ProjectionConversions&&) = delete;      // Move Assignment Not Implemented
};
