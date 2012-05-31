//-*- Mode: C++ -*-
// $Id$

/**************************************************************************
 * This file is property of and copyright by the ALICE HLT Project        * 
 * ALICE Experiment at CERN, All rights reserved.                         *
 *                                                                        *
 * Primary Authors: Chiara Oppedisano <Chiara.Oppedisano@to.infn.it>      *
 *                  for The ALICE HLT Project.                            *
 *                                                                        *
 * Permission to use, copy, modify and distribute this software and its   *
 * documentation strictly for non-commercial purposes is hereby granted   *
 * without fee, provided that the above copyright notice appears in all   *
 * copies and that both the copyright notice and this permission notice   *
 * appear in the supporting documentation. The authors make no claims     *
 * about the suitability of this software for any purpose. It is          *
 * provided "as is" without express or implied warranty.                  *
 **************************************************************************/

/** @file   AliHLTZDCAgent.cxx
    @author Chiara Oppedisano <Chiara.Oppedisano@to.infn.it>
    @brief  Agent of the libAliHLTZDC library
*/

#include <cassert>

#include "TSystem.h"

#include "AliHLTZDCAgent.h"

#include "AliHLTErrorGuard.h"

// header files of library components
#include "AliHLTZDCESDRecoComponent.h"

// raw data handler of HLTOUT data
#include "AliHLTOUTHandlerEquId.h"
#include "AliHLTOUTHandlerEsdBranch.h"

/** global instance for agent registration */
AliHLTZDCAgent gAliHLTZDCAgent;

/** ROOT macro for the implementation of ROOT specific class methods */
ClassImp(AliHLTZDCAgent)

AliHLTZDCAgent::AliHLTZDCAgent()  :
  AliHLTModuleAgent("ZDC")
{
  // see header file for class documentation
  // or
  // refer to README to build package
  // or
  // visit http://web.ift.uib.no/~kjeks/doc/alice-hlt
}

AliHLTZDCAgent::~AliHLTZDCAgent()
{
  // see header file for class documentation
}

int AliHLTZDCAgent::CreateConfigurations(AliHLTConfigurationHandler* handler,
					 AliRawReader* rawReader,
					 AliRunLoader* runloader) const
{
  // see header file for class documentation

  if (!handler) 
    return -EINVAL;

  if (rawReader || !runloader) {
    // AliSimulation: use the AliRawReaderPublisher if the raw reader is available
    // Alireconstruction: indicated by runloader==NULL, run always on raw data

    // -- Define the ZDC raw publisher
    // -----------------------------------
    TString arg("-equipmentid 3840 -datatype 'DDL_RAW ' 'ZDC ' -dataspec 0x01");
    handler->CreateConfiguration("ZDC-DP_0", "AliRawReaderPublisher", NULL , arg.Data());

    // -- Define the VZERO reconstruction components
    // -----------------------------------------------
    handler->CreateConfiguration("ZDC-RECO", "ZDCESDReco", "ZDC-DP_0", "");
  }
  else if (runloader && !rawReader) {
    // indicates AliSimulation with no RawReader available -> run on digits
    
    /* NOT Tested/ implemented yet
      handler->CreateConfiguration("DigitPublisher","AliLoaderPublisher",NULL,
      "-loader ZDCLoader -datatype 'ALITREED' 'ZDC '");
      handler->CreateConfiguration("Digit","ZDCReconstruction","DigitPublisher","");
    */
  }
  
  return 0;
}

const char* AliHLTZDCAgent::GetReconstructionChains(AliRawReader* /*rawReader*/,
						    AliRunLoader* /*runloader*/) const
{
  // see header file for class documentation
  
  // ZDC called only from the EsdConverter
  return NULL;
}

const char* AliHLTZDCAgent::GetRequiredComponentLibraries() const
{
  // see header file for class documentation
  return "libAliHLTUtil.so libAliHLTZDC.so";
}

int AliHLTZDCAgent::RegisterComponents(AliHLTComponentHandler* pHandler) const
{
  // see header file for class documentation
  assert(pHandler);
  if (!pHandler) return -EINVAL;
  pHandler->AddComponent(new AliHLTZDCESDRecoComponent);

  return 0;
}

int AliHLTZDCAgent::GetHandlerDescription(AliHLTComponentDataType dt,
					     AliHLTUInt32_t spec,
					     AliHLTOUTHandlerDesc& desc) const
{
  // see header file for class documentation
  if (dt==(kAliHLTDataTypeDDLRaw|kAliHLTDataOriginZDC)) {
      desc=AliHLTOUTHandlerDesc(kRawReader, dt, GetModuleId());
      HLTInfo("module %s handles data block type %s specification %d (0x%x)", 
	      GetModuleId(), AliHLTComponent::DataType2Text(dt).c_str(), spec, spec);
      return 1;
  }

  // add TObject data blocks of type {ESD_CONT:ZDC } to ESD
  if (dt==(kAliHLTDataTypeESDContent|kAliHLTDataOriginZDC)) {
      desc=AliHLTOUTHandlerDesc(kEsd, dt, GetModuleId());
      HLTInfo("module %s handles data block type %s specification %d (0x%x)", 
	      GetModuleId(), AliHLTComponent::DataType2Text(dt).c_str(), spec, spec);
      return 1;
  }

  return 0;
}

AliHLTOUTHandler* AliHLTZDCAgent::GetOutputHandler(AliHLTComponentDataType dt,
						   AliHLTUInt32_t /*spec*/)
{
  // see header file for class documentation
  if (dt==(kAliHLTDataTypeDDLRaw|kAliHLTDataOriginZDC)) {
    // use the default handler
    static AliHLTOUTHandlerEquId handler;
    return &handler;
  }

  if (dt==(kAliHLTDataTypeESDContent|kAliHLTDataOriginZDC)) {
    // use AliHLTOUTHandlerEsdBranch handler to add the TObject
    // to the ESD branch
    // Note: the object should have an appropriate name returned
    // by GetName(). Use SetName() to prepare the object before streaming
    static AliHLTOUTHandlerEsdBranch handler;
    return &handler;
  }

  return NULL;
}

int AliHLTZDCAgent::DeleteOutputHandler(AliHLTOUTHandler* pInstance)
{
  // see header file for class documentation
  if (pInstance==NULL) return -EINVAL;

  // nothing to delete, the handler have been defined static
  return 0;
}

// #################################################################################
AliHLTModulePreprocessor* AliHLTZDCAgent::GetPreprocessor() {
  // see header file for class documentation
  ALIHLTERRORGUARD(5, "GetPreProcessor not implemented for this module");
  return NULL;
}
