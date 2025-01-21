/*
 * SPDX-FileCopyrightText: 2022-2023 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Apache-2.0
 */
/* ULP Example: pulse counting

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.

   This file contains assembly code which runs on the ULP.

   ULP wakes up to run this code at a certain period, determined by the values
   in SENS_ULP_CP_SLEEP_CYCx_REG registers. On each wake up, the program checks
   the input on GPIO0. If the value is different from the previous one, the
   program "debounces" the input: on the next debounce_max_count wake ups,
   it expects to see the same value of input.
   If this condition holds true, the program increments edge_count and starts
   waiting for input signal polarity to change again.
*/

/* ULP assembly files are passed through C preprocessor first, so include directives
   and C macros may be used in these files
 */
#include "sdkconfig.h"
#include "soc/rtc_cntl_reg.h"
#include "soc/rtc_io_reg.h"
#include "soc/soc_ulp.h"
#include "soc/sens_reg.h"

  /* Define variables, which go into .bss section (zero-initialized data) */
  .bss
  /* Next input signal edge expected: 0 (negative) or 1 (positive) */
  .global next_edge
next_edge:
  .long 0

  /* Counter started when signal value changes.
     Edge is "debounced" when the counter reaches zero. */
  .global debounce_counter
debounce_counter:
  .long 0

  /* Value to which debounce_counter gets reset.
     Set by the main program. */
  .global debounce_max_count
debounce_max_count:
  .long 0

  /* Flag to be one, for detecting rising edges */
  .global rising_edge_en
rising_edge_en:
  .long 0

  /* Number of rising signal edges acquired since last read */
  .global rising_edge_count
rising_edge_count:
  .long 0

  /* Flag to be one, for detecting falling edges */
  .global falling_edge_en
falling_edge_en:
  .long 0

  /* Number of falling signal edges acquired since last read */
  .global falling_edge_count
falling_edge_count:
  .long 0

  /* Number of times program run since last read */
  .global run_count
run_count:
  .long 0

  /* Total number of signal edges acquired */
  .global edge_count_total
edge_count_total:
  .long 0

  /* Number of edges after which main SoC shall be woken up */
  .global edges_wakeup
edges_wakeup:
  .long 0

  /* Pin to be enabled prior to reading pulses. */
  .global en_io_pin
en_io_pin:
  .long 0

  /* Time in ms to keep the enable pin on. */
  .global en_io_time
en_io_time:
  .long 0

  /* RTC IO number used to sample the input signal.
     Set by main program. */
  .global io_number
io_number:
  .long 0

  /* Code goes into .text section */
  .text
  .global entry
entry:
  /* Increment run_count */
  move r3, run_count
  ld r2, r3, 0
  add r2, r2, 1
  st r2, r3, 0

  /* Enable pulse generator via IO pin, wait user specified ms */
  /* Load en_io_time, skip loop in case it is zero */
  move r0, en_io_time
  jump en_loop_skip, eq
  sub r0, r0, 1 /* Decr. time by 1, as we use this offset to detect if this feature is used */

  /* Get enable IO pin */
  move r0, en_io_pin
  ld r0, r0, 0

  /* Multiply pin number by 2 (each RTCIO requires 2 instructions) */
  lsh r0, r0, 1

  /* Make address absolute */
  move r1, en_io_pin_set
  add r0, r0, r1

  /* Jump to the correct instruction */
  jump r0

en_io_pin_set:
  /* RTCIO 0 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 0, 1, 1)
  jump en_loop_wait

  /* RTCIO 1 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 1, 1, 1)
  jump en_loop_wait

  /* RTCIO 2 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 2, 1, 1)
  jump en_loop_wait

  /* RTCIO 3 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 3, 1, 1)
  jump en_loop_wait

  /* RTCIO 4 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 4, 1, 1)
  jump en_loop_wait

  /* RTCIO 5 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 5, 1, 1)
  jump en_loop_wait

  /* RTCIO 6 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 6, 1, 1)
  jump en_loop_wait

  /* RTCIO 7 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 7, 1, 1)
  jump en_loop_wait

  /* RTCIO 8 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 8, 1, 1)
  jump en_loop_wait

  /* RTCIO 9 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 9, 1, 1)
  jump en_loop_wait

  /* RTCIO 10 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 10, 1, 1)
  jump en_loop_wait

  /* RTCIO 11 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 11, 1, 1)
  jump en_loop_wait

  /* RTCIO 12 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 12, 1, 1)
  jump en_loop_wait

  /* RTCIO 13 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 13, 1, 1)
  jump en_loop_wait

  /* RTCIO 14 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 14, 1, 1)
  jump en_loop_wait

  /* RTCIO 15 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 15, 1, 1)
  jump en_loop_wait

  /* RTCIO 16 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 16, 1, 1)
  jump en_loop_wait

  /* RTCIO 17 HIGH */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TS_S + 17, 1, 1)
  jump en_loop_wait
  /*WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG,RTC_GPIO_OUT_DATA_W1TS_S+4,1,1)*/

  /* Wait user specified number of ms, assuming a frequency of 8MHz */
en_loop_wait:
  wait 4000                  /* Assuming 8 MHz fixed wait time of 4000cycles = 0.5ms */
  sub r0, r0, 1              /* Decre. loop variable */
  jumpr en_loop_wait, 0, gt      /* Stop loop once loop variable reached zero */

en_loop_skip:

  /* Load io_number */
  move r3, io_number
  ld r3, r3, 0

#if CONFIG_IDF_TARGET_ESP32S2
    /* ESP32S2 powers down RTC periph when entering deep sleep and thus by association SENS_SAR_IO_MUX_CONF_REG */
  WRITE_RTC_FIELD(SENS_SAR_IO_MUX_CONF_REG, SENS_IOMUX_CLK_GATE_EN, 1)
#elif CONFIG_IDF_TARGET_ESP32S3
    /* ESP32S3 powers down RTC periph when entering deep sleep and thus by association SENS_SAR_PERI_CLK_GATE_CONF_REG */
    WRITE_RTC_FIELD(SENS_SAR_PERI_CLK_GATE_CONF_REG, SENS_IOMUX_CLK_EN, 1);
#endif

  /* Lower 16 IOs and higher need to be handled separately,
   * because r0-r3 registers are 16 bit wide.
   * Check which IO this is.
   */
  move r0, r3
  jumpr read_io_high, 16, ge

  /* Read the value of lower 16 RTC IOs into R0 */
  READ_RTC_REG(RTC_GPIO_IN_REG, RTC_GPIO_IN_NEXT_S, 16)
  rsh r0, r0, r3
  jump read_done

  /* Read the value of RTC IOs 16-17, into R0 */
read_io_high:
  READ_RTC_REG(RTC_GPIO_IN_REG, RTC_GPIO_IN_NEXT_S + 16, 2)
  sub r3, r3, 16
  rsh r0, r0, r3

read_done:
  and r3, r0, 1

  /* Disable pulse generator via IO pin */
  /* Check if en/dis pin is active */
  move r0, en_io_time
  jump dis_en_skip, eq

  /* Set en_io_pin low */

  /* Get enable IO pin */
  move r0, en_io_pin
  ld r0, r0, 0

  /* Multiply pin number by 2 (each RTCIO requires 2 instructions) */
  lsh r0, r0, 1

  /* Make address absolute */
  move r1, en_io_pin_clear
  add r0, r0, r1

  /* Jump to the correct instruction */
  jump r0

en_io_pin_clear:
  /* RTCIO 0 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 0, 1, 1)
  jump dis_en_skip

  /* RTCIO 1 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 1, 1, 1)
  jump dis_en_skip

  /* RTCIO 2 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 2, 1, 1)
  jump dis_en_skip

  /* RTCIO 3 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 3, 1, 1)
  jump dis_en_skip

  /* RTCIO 4 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 4, 1, 1)
  jump dis_en_skip

  /* RTCIO 5 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 5, 1, 1)
  jump dis_en_skip

  /* RTCIO 6 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 6, 1, 1)
  jump dis_en_skip

  /* RTCIO 7 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 7, 1, 1)
  jump dis_en_skip

  /* RTCIO 8 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 8, 1, 1)
  jump dis_en_skip

  /* RTCIO 9 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 9, 1, 1)
  jump dis_en_skip

  /* RTCIO 10 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 10, 1, 1)
  jump dis_en_skip

  /* RTCIO 11 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 11, 1, 1)
  jump dis_en_skip

  /* RTCIO 12 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 12, 1, 1)
  jump dis_en_skip

  /* RTCIO 13 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 13, 1, 1)
  jump dis_en_skip

  /* RTCIO 14 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 14, 1, 1)
  jump dis_en_skip

  /* RTCIO 15 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 15, 1, 1)
  jump dis_en_skip

  /* RTCIO 16 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 16, 1, 1)
  jump dis_en_skip

  /* RTCIO 17 LOW */
  WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 17, 1, 1)
  jump dis_en_skip
  /*WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG, RTC_GPIO_OUT_DATA_W1TC_S + 4, 1, 1)*/

dis_en_skip:

  /* State of input changed? */
  move r2, next_edge
  ld r0, r2, 0
  jumpr skip_next_edge_init, 4, lt
  /* In first run init next_edge with the current state */
  move r0, r3 /* Load current state */
  add r0, r0, 1 /* Negate it */
  and r0, r0, 1 /* = */
  st r0, r2, 0 /* Store to next_edge */
skip_next_edge_init:
  add r3, r3, r0
  and r3, r3, 1
  jump changed, eq
  /* Not changed */
  /* Reset debounce_counter to debounce_max_count */
  move r3, debounce_max_count
  move r2, debounce_counter
  ld r3, r3, 0
  st r3, r2, 0
  /* End program */
  halt

  .global changed
changed:
  /* Input state changed */
  /* Has debounce_counter reached zero? */
  move r3, debounce_counter
  ld r2, r3, 0
  add r2, r2, 0 /* dummy ADD to use "jump if ALU result is zero" */
  jump edge_detected, eq
  /* Not yet. Decrement debounce_counter */
  sub r2, r2, 1
  st r2, r3, 0
  /* End program */
  halt

  .global edge_detected
edge_detected:
  /* Reset debounce_counter to debounce_max_count */
  move r3, debounce_max_count
  move r2, debounce_counter
  ld r3, r3, 0
  st r3, r2, 0
  /* Flip next_edge */
  move r3, next_edge
  ld r2, r3, 0
  add r2, r2, 1
  and r2, r2, 1
  st r2, r3, 0
  /* Jump to increment of current edge counter */
  add r2, r2, 0 /* dummy ADD to use "jump if ALU result is zero" */
  jump rising, eq

  .global falling
falling:
  /* Check if detecting falling edges is enabled */
  move r3, falling_edge_en
  ld r2, r3, 0
  add r2, r2, 0 /* dummy ADD to use "jump if ALU result is zero" */
  jump wake_up_skip, eq

  /* Increment falling_edge_count */
  move r3, falling_edge_count
  ld r2, r3, 0
  add r2, r2, 1
  st r2, r3, 0
  jump wake_up

  .global rising
rising:
  /* Check if detecting rising edges is enabled */
  move r3, rising_edge_en
  ld r2, r3, 0
  add r2, r2, 0 /* dummy ADD to use "jump if ALU result is zero" */
  jump wake_up_skip, eq

  /* Increment rising_edge_count */
  move r3, rising_edge_count
  ld r2, r3, 0
  add r2, r2, 1
  st r2, r3, 0
  jump wake_up

  .global wake_up
wake_up:
  /* Check if the system can be woken up. Checking here to not increment
    edge wait counter while being awake. We want to wake the system after
    counting the user specified number while being asleep. */
  READ_RTC_FIELD(RTC_CNTL_LOW_POWER_ST_REG, RTC_CNTL_RDY_FOR_WAKEUP)
  and r0, r0, 1
  jump am_awake, eq

  /* Increment edge_count_total */
  move r2, edge_count_total
  ld r1, r2, 0
  add r1, r1, 1
  st r1, r2, 0

  /* compare with edges_wakeup; wake up if edge_count_total >= edges_wakeup */
  move r0, edges_wakeup
  ld r1, r0, 0
  move r0, edge_count_total
  ld r2, r0, 0
  sub r0, r1, r2
  jumpr wake_up_skip, 0, gt /* jump if edges_wakeup - edge_count_total > 0  */

  .global am_awake
am_awake:

  /* Reset total edge counter */
  move r2, 0
  move r1, edge_count_total
  st r2, r1, 0

  /* Check if the system can be woken up. Checking again to prevent wake
    whilen not being asleep */
  READ_RTC_FIELD(RTC_CNTL_LOW_POWER_ST_REG, RTC_CNTL_RDY_FOR_WAKEUP)
  and r0, r0, 1
  jump wake_up_skip, eq

  /* Wake up the SoC, end program */
  wake

  .global wake_up_skip
wake_up_skip:
  halt
