#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <stdio.h>

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>

#define cmd_opcode_pack(ogf, ocf) (uint16_t)((ocf & 0x03ff)|(ogf << 10))

#define EIR_FLAGS                   0X01
#define EIR_NAME_SHORT              0x08
#define EIR_NAME_COMPLETE           0x09
#define EIR_MANUFACTURE_SPECIFIC    0xFF

int global_done = 0;

unsigned int *uuid_str_to_data(char *uuid)
{
  char conv[] = "0123456789ABCDEF";
  int len = strlen(uuid);
  unsigned int *data = (unsigned int*)malloc(sizeof(unsigned int) * len);
  unsigned int *dp = data;
  char *cu = uuid;

  for(; cu<uuid+len; dp++,cu+=2)
  {
    *dp = ((strchr(conv, toupper(*cu)) - conv) * 16) 
        + (strchr(conv, toupper(*(cu+1))) - conv);
  }

  return data;
}

unsigned int twoc(int in, int t)
{
  return (in < 0) ? (in + (2 << (t-1))) : in;
}

int enable_advertising(int advertising_interval, char *advertising_uuid, int major_number, int minor_number, int rssi_value)
{
  int device_id = hci_get_route(NULL);

  int device_handle = 0;
  if((device_handle = hci_open_dev(device_id)) < 0)
  {
    perror("Could not open device");
    exit(1);
  }

  le_set_advertising_parameters_cp adv_params_cp;
  memset(&adv_params_cp, 0, sizeof(adv_params_cp));
  adv_params_cp.min_interval = htobs(advertising_interval);
  adv_params_cp.max_interval = htobs(advertising_interval);
  adv_params_cp.chan_map = 7;

  uint8_t status;
  struct hci_request rq;
  memset(&rq, 0, sizeof(rq));
  rq.ogf = OGF_LE_CTL;
  rq.ocf = OCF_LE_SET_ADVERTISING_PARAMETERS;
  rq.cparam = &adv_params_cp;
  rq.clen = LE_SET_ADVERTISING_PARAMETERS_CP_SIZE;
  rq.rparam = &status;
  rq.rlen = 1;

  int ret = hci_send_req(device_handle, &rq, 1000);
  if (ret < 0)
  {
    hci_close_dev(device_handle);
    fprintf(stderr, "Can't send request %s (%d)\n", strerror(errno), errno);
    return(1);
  }

  le_set_advertise_enable_cp advertise_cp;
  memset(&advertise_cp, 0, sizeof(advertise_cp));
  advertise_cp.enable = 0x01;

  memset(&rq, 0, sizeof(rq));
  rq.ogf = OGF_LE_CTL;
  rq.ocf = OCF_LE_SET_ADVERTISE_ENABLE;
  rq.cparam = &advertise_cp;
  rq.clen = LE_SET_ADVERTISE_ENABLE_CP_SIZE;
  rq.rparam = &status;
  rq.rlen = 1;

  ret = hci_send_req(device_handle, &rq, 1000);

  if (ret < 0)
  {
    hci_close_dev(device_handle);
    fprintf(stderr, "Can't send request %s (%d)\n", strerror(errno), errno);
    return(1);
  }

  le_set_advertising_data_cp adv_data_cp;
  memset(&adv_data_cp, 0, sizeof(adv_data_cp));

  uint8_t segment_length = 1;
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(EIR_FLAGS); segment_length++;
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(0x1A); segment_length++;
  adv_data_cp.data[adv_data_cp.length] = htobs(segment_length - 1);

  adv_data_cp.length += segment_length;

  segment_length = 1;
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(EIR_MANUFACTURE_SPECIFIC); segment_length++;
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(0x4C); segment_length++;
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(0x00); segment_length++;
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(0x02); segment_length++;
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(0x15); segment_length++;

  unsigned int *uuid = uuid_str_to_data(advertising_uuid);
  int i;
  for(i=0; i<strlen(advertising_uuid)/2; i++)
  {
    adv_data_cp.data[adv_data_cp.length + segment_length]  = htobs(uuid[i]); segment_length++;
  }

  // Major number
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(major_number >> 8 & 0x00FF); segment_length++;
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(major_number & 0x00FF); segment_length++;

  // Minor number
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(minor_number >> 8 & 0x00FF); segment_length++;
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(minor_number & 0x00FF); segment_length++;

  // RSSI calibration
  adv_data_cp.data[adv_data_cp.length + segment_length] = htobs(twoc(rssi_value, 8)); segment_length++;

  adv_data_cp.data[adv_data_cp.length] = htobs(segment_length - 1);

  adv_data_cp.length += segment_length;

  memset(&rq, 0, sizeof(rq));
  rq.ogf = OGF_LE_CTL;
  rq.ocf = OCF_LE_SET_ADVERTISING_DATA;
  rq.cparam = &adv_data_cp;
  rq.clen = LE_SET_ADVERTISING_DATA_CP_SIZE;
  rq.rparam = &status;
  rq.rlen = 1;

  ret = hci_send_req(device_handle, &rq, 1000);

  hci_close_dev(device_handle);

  if(ret < 0)
  {
    fprintf(stderr, "Can't send request %s (%d)\n", strerror(errno), errno);
    return(1);
  }

  if (status) 
  {
    fprintf(stderr, "LE set advertise returned status %d\n", status);
    return(1);
  }
}

int disable_advertising()
{
  int device_id = hci_get_route(NULL);

  int device_handle = 0;
  if((device_handle = hci_open_dev(device_id)) < 0)
  {
    perror("Could not open device");
    return(1);
  }

  le_set_advertise_enable_cp advertise_cp;
  uint8_t status;

  memset(&advertise_cp, 0, sizeof(advertise_cp));

  struct hci_request rq;
  memset(&rq, 0, sizeof(rq));
  rq.ogf = OGF_LE_CTL;
  rq.ocf = OCF_LE_SET_ADVERTISE_ENABLE;
  rq.cparam = &advertise_cp;
  rq.clen = LE_SET_ADVERTISE_ENABLE_CP_SIZE;
  rq.rparam = &status;
  rq.rlen = 1;

  int ret = hci_send_req(device_handle, &rq, 1000);

  hci_close_dev(device_handle);

  if (ret < 0) 
  {
    fprintf(stderr, "Can't set advertise mode: %s (%d)\n", strerror(errno), errno);
    return(1);
  }

  if (status) 
  {
    fprintf(stderr, "LE set advertise enable on returned status %d\n", status);
    return(1);
  }
}

void ctrlc_handler(int s)
{
  global_done = 1;
}

void main(int argc, char **argv)
{
  if(argc != 6)
  {
    fprintf(stderr, "Usage: %s <advertisement time in ms> <UUID> <major number> <minor number> <RSSI calibration amount>\n", argv[0]);
    exit(1);
  }

  int rc = enable_advertising(atoi(argv[1]), argv[2], atoi(argv[3]), atoi(argv[4]), atoi(argv[5]));
  if(rc == 0)
  {
    struct sigaction sigint_handler;

    sigint_handler.sa_handler = ctrlc_handler;
    sigemptyset(&sigint_handler.sa_mask);
    sigint_handler.sa_flags = 0;

    sigaction(SIGINT, &sigint_handler, NULL);

    fprintf(stderr, "Hit ctrl-c to stop advertising\n");

    while(!global_done) { sleep(1); }

    fprintf(stderr, "Shutting down\n");
    disable_advertising();
  }
}
