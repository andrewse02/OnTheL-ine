/* This file was generated by upbc (the upb compiler) from the input
 * file:
 *
 *     envoy/service/listener/v3/lds.proto
 *
 * Do not edit -- your changes will be discarded when the file is
 * regenerated. */

#include "upb/def.h"
#include "envoy/service/listener/v3/lds.upbdefs.h"
#include "envoy/service/listener/v3/lds.upb.h"

extern upb_def_init envoy_service_discovery_v3_discovery_proto_upbdefinit;
extern upb_def_init google_api_annotations_proto_upbdefinit;
extern upb_def_init envoy_annotations_resource_proto_upbdefinit;
extern upb_def_init udpa_annotations_status_proto_upbdefinit;
extern upb_def_init udpa_annotations_versioning_proto_upbdefinit;
static const char descriptor[825] = {'\n', '#', 'e', 'n', 'v', 'o', 'y', '/', 's', 'e', 'r', 'v', 'i', 'c', 'e', '/', 'l', 'i', 's', 't', 'e', 'n', 'e', 'r', '/', 
'v', '3', '/', 'l', 'd', 's', '.', 'p', 'r', 'o', 't', 'o', '\022', '\031', 'e', 'n', 'v', 'o', 'y', '.', 's', 'e', 'r', 'v', 'i', 
'c', 'e', '.', 'l', 'i', 's', 't', 'e', 'n', 'e', 'r', '.', 'v', '3', '\032', '*', 'e', 'n', 'v', 'o', 'y', '/', 's', 'e', 'r', 
'v', 'i', 'c', 'e', '/', 'd', 'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', '/', 'v', '3', '/', 'd', 'i', 's', 'c', 'o', 'v', 'e', 
'r', 'y', '.', 'p', 'r', 'o', 't', 'o', '\032', '\034', 'g', 'o', 'o', 'g', 'l', 'e', '/', 'a', 'p', 'i', '/', 'a', 'n', 'n', 'o', 
't', 'a', 't', 'i', 'o', 'n', 's', '.', 'p', 'r', 'o', 't', 'o', '\032', ' ', 'e', 'n', 'v', 'o', 'y', '/', 'a', 'n', 'n', 'o', 
't', 'a', 't', 'i', 'o', 'n', 's', '/', 'r', 'e', 's', 'o', 'u', 'r', 'c', 'e', '.', 'p', 'r', 'o', 't', 'o', '\032', '\035', 'u', 
'd', 'p', 'a', '/', 'a', 'n', 'n', 'o', 't', 'a', 't', 'i', 'o', 'n', 's', '/', 's', 't', 'a', 't', 'u', 's', '.', 'p', 'r', 
'o', 't', 'o', '\032', '!', 'u', 'd', 'p', 'a', '/', 'a', 'n', 'n', 'o', 't', 'a', 't', 'i', 'o', 'n', 's', '/', 'v', 'e', 'r', 
's', 'i', 'o', 'n', 'i', 'n', 'g', '.', 'p', 'r', 'o', 't', 'o', '\"', '(', '\n', '\010', 'L', 'd', 's', 'D', 'u', 'm', 'm', 'y', 
':', '\034', '\232', '\305', '\210', '\036', '\027', '\n', '\025', 'e', 'n', 'v', 'o', 'y', '.', 'a', 'p', 'i', '.', 'v', '2', '.', 'L', 'd', 's', 
'D', 'u', 'm', 'm', 'y', '2', '\324', '\003', '\n', '\030', 'L', 'i', 's', 't', 'e', 'n', 'e', 'r', 'D', 'i', 's', 'c', 'o', 'v', 'e', 
'r', 'y', 'S', 'e', 'r', 'v', 'i', 'c', 'e', '\022', '}', '\n', '\016', 'D', 'e', 'l', 't', 'a', 'L', 'i', 's', 't', 'e', 'n', 'e', 
'r', 's', '\022', '1', '.', 'e', 'n', 'v', 'o', 'y', '.', 's', 'e', 'r', 'v', 'i', 'c', 'e', '.', 'd', 'i', 's', 'c', 'o', 'v', 
'e', 'r', 'y', '.', 'v', '3', '.', 'D', 'e', 'l', 't', 'a', 'D', 'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', 'R', 'e', 'q', 'u', 
'e', 's', 't', '\032', '2', '.', 'e', 'n', 'v', 'o', 'y', '.', 's', 'e', 'r', 'v', 'i', 'c', 'e', '.', 'd', 'i', 's', 'c', 'o', 
'v', 'e', 'r', 'y', '.', 'v', '3', '.', 'D', 'e', 'l', 't', 'a', 'D', 'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', 'R', 'e', 's', 
'p', 'o', 'n', 's', 'e', '\"', '\000', '(', '\001', '0', '\001', '\022', 't', '\n', '\017', 'S', 't', 'r', 'e', 'a', 'm', 'L', 'i', 's', 't', 
'e', 'n', 'e', 'r', 's', '\022', ',', '.', 'e', 'n', 'v', 'o', 'y', '.', 's', 'e', 'r', 'v', 'i', 'c', 'e', '.', 'd', 'i', 's', 
'c', 'o', 'v', 'e', 'r', 'y', '.', 'v', '3', '.', 'D', 'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', 'R', 'e', 'q', 'u', 'e', 's', 
't', '\032', '-', '.', 'e', 'n', 'v', 'o', 'y', '.', 's', 'e', 'r', 'v', 'i', 'c', 'e', '.', 'd', 'i', 's', 'c', 'o', 'v', 'e', 
'r', 'y', '.', 'v', '3', '.', 'D', 'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', 'R', 'e', 's', 'p', 'o', 'n', 's', 'e', '\"', '\000', 
'(', '\001', '0', '\001', '\022', '\227', '\001', '\n', '\016', 'F', 'e', 't', 'c', 'h', 'L', 'i', 's', 't', 'e', 'n', 'e', 'r', 's', '\022', ',', 
'.', 'e', 'n', 'v', 'o', 'y', '.', 's', 'e', 'r', 'v', 'i', 'c', 'e', '.', 'd', 'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', '.', 
'v', '3', '.', 'D', 'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', 'R', 'e', 'q', 'u', 'e', 's', 't', '\032', '-', '.', 'e', 'n', 'v', 
'o', 'y', '.', 's', 'e', 'r', 'v', 'i', 'c', 'e', '.', 'd', 'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', '.', 'v', '3', '.', 'D', 
'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', 'R', 'e', 's', 'p', 'o', 'n', 's', 'e', '\"', '(', '\202', '\323', '\344', '\223', '\002', '\031', '\"', 
'\027', '/', 'v', '3', '/', 'd', 'i', 's', 'c', 'o', 'v', 'e', 'r', 'y', ':', 'l', 'i', 's', 't', 'e', 'n', 'e', 'r', 's', '\202', 
'\323', '\344', '\223', '\002', '\003', ':', '\001', '*', '\032', ')', '\212', '\244', '\226', '\363', '\007', '#', '\n', '!', 'e', 'n', 'v', 'o', 'y', '.', 'c', 
'o', 'n', 'f', 'i', 'g', '.', 'l', 'i', 's', 't', 'e', 'n', 'e', 'r', '.', 'v', '3', '.', 'L', 'i', 's', 't', 'e', 'n', 'e', 
'r', 'B', '@', '\n', '\'', 'i', 'o', '.', 'e', 'n', 'v', 'o', 'y', 'p', 'r', 'o', 'x', 'y', '.', 'e', 'n', 'v', 'o', 'y', '.', 
's', 'e', 'r', 'v', 'i', 'c', 'e', '.', 'l', 'i', 's', 't', 'e', 'n', 'e', 'r', '.', 'v', '3', 'B', '\010', 'L', 'd', 's', 'P', 
'r', 'o', 't', 'o', 'P', '\001', '\210', '\001', '\001', '\272', '\200', '\310', '\321', '\006', '\002', '\020', '\002', 'b', '\006', 'p', 'r', 'o', 't', 'o', '3', 
};

static upb_def_init *deps[6] = {
  &envoy_service_discovery_v3_discovery_proto_upbdefinit,
  &google_api_annotations_proto_upbdefinit,
  &envoy_annotations_resource_proto_upbdefinit,
  &udpa_annotations_status_proto_upbdefinit,
  &udpa_annotations_versioning_proto_upbdefinit,
  NULL
};

upb_def_init envoy_service_listener_v3_lds_proto_upbdefinit = {
  deps,
  &envoy_service_listener_v3_lds_proto_upb_file_layout,
  "envoy/service/listener/v3/lds.proto",
  UPB_STRVIEW_INIT(descriptor, 825)
};
