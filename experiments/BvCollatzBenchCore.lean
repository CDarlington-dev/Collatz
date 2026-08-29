import Lean.Elab.Tactic.BVDecide
import Lean.Meta.Tactic.BVDecide.Normalize
import Mathlib.Data.Nat.Log
import Std.Tactic.BVDecide

/-!
Instrumented SAT feasibility prototype for the finite Collatz classification.

This file is deliberately isolated from the production library.  `bv_bench`
uses the stock BVDecide proof path, but also writes the exact bit-blasted CNF
before invoking CaDiCaL and logs its AIG/CNF dimensions.  The companion driver
files each contain one benchmark theorem so their costs can be measured alone.
-/

namespace BvCollatzBench

abbrev Input := BitVec 30
abbrev Value := BitVec 64
abbrev Odds := BitVec 10

def maxSafeOddInput : Value := BitVec.ofNat 64 6148914691236517204

def isOdd (x : Value) : Bool := x.getLsbD 0

/-- Logical division by two, expressed in primitives reified even under a `bif`. -/
def half (x : Value) : Value :=
  0#1 ++ BitVec.extractLsb' 1 63 x

def accelerated (x : Value) : Value :=
  if isOdd x then half ((3 : Value) * x + 1) else half x

def oddContribution (b : Bool) : Odds :=
  (BitVec.ofBool b).zeroExtend 10

attribute [bv_normalize] isOdd half accelerated oddContribution

/- Largest `q` for which `3^q < 2^j`.  The result is below 389 for `j ≤ 616`. -/
/-- Exact threshold table for the benchmark horizon.  The fallback is unused. -/
def qBoundNat : Nat → Nat
  | 0 => 0
  | 1 => 0
  | 2 => 1
  | 3 => 1
  | 4 => 2
  | 5 => 3
  | 6 => 3
  | 7 => 4
  | 8 => 5
  | 9 => 5
  | 10 => 6
  | 11 => 6
  | 12 => 7
  | 13 => 8
  | 14 => 8
  | 15 => 9
  | 16 => 10
  | 17 => 10
  | 18 => 11
  | 19 => 11
  | 20 => 12
  | 21 => 13
  | 22 => 13
  | 23 => 14
  | 24 => 15
  | 25 => 15
  | 26 => 16
  | 27 => 17
  | 28 => 17
  | 29 => 18
  | 30 => 18
  | 31 => 19
  | 32 => 20
  | 33 => 20
  | 34 => 21
  | 35 => 22
  | 36 => 22
  | 37 => 23
  | 38 => 23
  | 39 => 24
  | 40 => 25
  | 41 => 25
  | 42 => 26
  | 43 => 27
  | 44 => 27
  | 45 => 28
  | 46 => 29
  | 47 => 29
  | 48 => 30
  | 49 => 30
  | 50 => 31
  | 51 => 32
  | 52 => 32
  | 53 => 33
  | 54 => 34
  | 55 => 34
  | 56 => 35
  | 57 => 35
  | 58 => 36
  | 59 => 37
  | 60 => 37
  | 61 => 38
  | 62 => 39
  | 63 => 39
  | 64 => 40
  | 65 => 41
  | 66 => 41
  | 67 => 42
  | 68 => 42
  | 69 => 43
  | 70 => 44
  | 71 => 44
  | 72 => 45
  | 73 => 46
  | 74 => 46
  | 75 => 47
  | 76 => 47
  | 77 => 48
  | 78 => 49
  | 79 => 49
  | 80 => 50
  | 81 => 51
  | 82 => 51
  | 83 => 52
  | 84 => 52
  | 85 => 53
  | 86 => 54
  | 87 => 54
  | 88 => 55
  | 89 => 56
  | 90 => 56
  | 91 => 57
  | 92 => 58
  | 93 => 58
  | 94 => 59
  | 95 => 59
  | 96 => 60
  | 97 => 61
  | 98 => 61
  | 99 => 62
  | 100 => 63
  | 101 => 63
  | 102 => 64
  | 103 => 64
  | 104 => 65
  | 105 => 66
  | 106 => 66
  | 107 => 67
  | 108 => 68
  | 109 => 68
  | 110 => 69
  | 111 => 70
  | 112 => 70
  | 113 => 71
  | 114 => 71
  | 115 => 72
  | 116 => 73
  | 117 => 73
  | 118 => 74
  | 119 => 75
  | 120 => 75
  | 121 => 76
  | 122 => 76
  | 123 => 77
  | 124 => 78
  | 125 => 78
  | 126 => 79
  | 127 => 80
  | 128 => 80
  | 129 => 81
  | 130 => 82
  | 131 => 82
  | 132 => 83
  | 133 => 83
  | 134 => 84
  | 135 => 85
  | 136 => 85
  | 137 => 86
  | 138 => 87
  | 139 => 87
  | 140 => 88
  | 141 => 88
  | 142 => 89
  | 143 => 90
  | 144 => 90
  | 145 => 91
  | 146 => 92
  | 147 => 92
  | 148 => 93
  | 149 => 94
  | 150 => 94
  | 151 => 95
  | 152 => 95
  | 153 => 96
  | 154 => 97
  | 155 => 97
  | 156 => 98
  | 157 => 99
  | 158 => 99
  | 159 => 100
  | 160 => 100
  | 161 => 101
  | 162 => 102
  | 163 => 102
  | 164 => 103
  | 165 => 104
  | 166 => 104
  | 167 => 105
  | 168 => 105
  | 169 => 106
  | 170 => 107
  | 171 => 107
  | 172 => 108
  | 173 => 109
  | 174 => 109
  | 175 => 110
  | 176 => 111
  | 177 => 111
  | 178 => 112
  | 179 => 112
  | 180 => 113
  | 181 => 114
  | 182 => 114
  | 183 => 115
  | 184 => 116
  | 185 => 116
  | 186 => 117
  | 187 => 117
  | 188 => 118
  | 189 => 119
  | 190 => 119
  | 191 => 120
  | 192 => 121
  | 193 => 121
  | 194 => 122
  | 195 => 123
  | 196 => 123
  | 197 => 124
  | 198 => 124
  | 199 => 125
  | 200 => 126
  | 201 => 126
  | 202 => 127
  | 203 => 128
  | 204 => 128
  | 205 => 129
  | 206 => 129
  | 207 => 130
  | 208 => 131
  | 209 => 131
  | 210 => 132
  | 211 => 133
  | 212 => 133
  | 213 => 134
  | 214 => 135
  | 215 => 135
  | 216 => 136
  | 217 => 136
  | 218 => 137
  | 219 => 138
  | 220 => 138
  | 221 => 139
  | 222 => 140
  | 223 => 140
  | 224 => 141
  | 225 => 141
  | 226 => 142
  | 227 => 143
  | 228 => 143
  | 229 => 144
  | 230 => 145
  | 231 => 145
  | 232 => 146
  | 233 => 147
  | 234 => 147
  | 235 => 148
  | 236 => 148
  | 237 => 149
  | 238 => 150
  | 239 => 150
  | 240 => 151
  | 241 => 152
  | 242 => 152
  | 243 => 153
  | 244 => 153
  | 245 => 154
  | 246 => 155
  | 247 => 155
  | 248 => 156
  | 249 => 157
  | 250 => 157
  | 251 => 158
  | 252 => 158
  | 253 => 159
  | 254 => 160
  | 255 => 160
  | 256 => 161
  | 257 => 162
  | 258 => 162
  | 259 => 163
  | 260 => 164
  | 261 => 164
  | 262 => 165
  | 263 => 165
  | 264 => 166
  | 265 => 167
  | 266 => 167
  | 267 => 168
  | 268 => 169
  | 269 => 169
  | 270 => 170
  | 271 => 170
  | 272 => 171
  | 273 => 172
  | 274 => 172
  | 275 => 173
  | 276 => 174
  | 277 => 174
  | 278 => 175
  | 279 => 176
  | 280 => 176
  | 281 => 177
  | 282 => 177
  | 283 => 178
  | 284 => 179
  | 285 => 179
  | 286 => 180
  | 287 => 181
  | 288 => 181
  | 289 => 182
  | 290 => 182
  | 291 => 183
  | 292 => 184
  | 293 => 184
  | 294 => 185
  | 295 => 186
  | 296 => 186
  | 297 => 187
  | 298 => 188
  | 299 => 188
  | 300 => 189
  | 301 => 189
  | 302 => 190
  | 303 => 191
  | 304 => 191
  | 305 => 192
  | 306 => 193
  | 307 => 193
  | 308 => 194
  | 309 => 194
  | 310 => 195
  | 311 => 196
  | 312 => 196
  | 313 => 197
  | 314 => 198
  | 315 => 198
  | 316 => 199
  | 317 => 200
  | 318 => 200
  | 319 => 201
  | 320 => 201
  | 321 => 202
  | 322 => 203
  | 323 => 203
  | 324 => 204
  | 325 => 205
  | 326 => 205
  | 327 => 206
  | 328 => 206
  | 329 => 207
  | 330 => 208
  | 331 => 208
  | 332 => 209
  | 333 => 210
  | 334 => 210
  | 335 => 211
  | 336 => 211
  | 337 => 212
  | 338 => 213
  | 339 => 213
  | 340 => 214
  | 341 => 215
  | 342 => 215
  | 343 => 216
  | 344 => 217
  | 345 => 217
  | 346 => 218
  | 347 => 218
  | 348 => 219
  | 349 => 220
  | 350 => 220
  | 351 => 221
  | 352 => 222
  | 353 => 222
  | 354 => 223
  | 355 => 223
  | 356 => 224
  | 357 => 225
  | 358 => 225
  | 359 => 226
  | 360 => 227
  | 361 => 227
  | 362 => 228
  | 363 => 229
  | 364 => 229
  | 365 => 230
  | 366 => 230
  | 367 => 231
  | 368 => 232
  | 369 => 232
  | 370 => 233
  | 371 => 234
  | 372 => 234
  | 373 => 235
  | 374 => 235
  | 375 => 236
  | 376 => 237
  | 377 => 237
  | 378 => 238
  | 379 => 239
  | 380 => 239
  | 381 => 240
  | 382 => 241
  | 383 => 241
  | 384 => 242
  | 385 => 242
  | 386 => 243
  | 387 => 244
  | 388 => 244
  | 389 => 245
  | 390 => 246
  | 391 => 246
  | 392 => 247
  | 393 => 247
  | 394 => 248
  | 395 => 249
  | 396 => 249
  | 397 => 250
  | 398 => 251
  | 399 => 251
  | 400 => 252
  | 401 => 253
  | 402 => 253
  | 403 => 254
  | 404 => 254
  | 405 => 255
  | 406 => 256
  | 407 => 256
  | 408 => 257
  | 409 => 258
  | 410 => 258
  | 411 => 259
  | 412 => 259
  | 413 => 260
  | 414 => 261
  | 415 => 261
  | 416 => 262
  | 417 => 263
  | 418 => 263
  | 419 => 264
  | 420 => 264
  | 421 => 265
  | 422 => 266
  | 423 => 266
  | 424 => 267
  | 425 => 268
  | 426 => 268
  | 427 => 269
  | 428 => 270
  | 429 => 270
  | 430 => 271
  | 431 => 271
  | 432 => 272
  | 433 => 273
  | 434 => 273
  | 435 => 274
  | 436 => 275
  | 437 => 275
  | 438 => 276
  | 439 => 276
  | 440 => 277
  | 441 => 278
  | 442 => 278
  | 443 => 279
  | 444 => 280
  | 445 => 280
  | 446 => 281
  | 447 => 282
  | 448 => 282
  | 449 => 283
  | 450 => 283
  | 451 => 284
  | 452 => 285
  | 453 => 285
  | 454 => 286
  | 455 => 287
  | 456 => 287
  | 457 => 288
  | 458 => 288
  | 459 => 289
  | 460 => 290
  | 461 => 290
  | 462 => 291
  | 463 => 292
  | 464 => 292
  | 465 => 293
  | 466 => 294
  | 467 => 294
  | 468 => 295
  | 469 => 295
  | 470 => 296
  | 471 => 297
  | 472 => 297
  | 473 => 298
  | 474 => 299
  | 475 => 299
  | 476 => 300
  | 477 => 300
  | 478 => 301
  | 479 => 302
  | 480 => 302
  | 481 => 303
  | 482 => 304
  | 483 => 304
  | 484 => 305
  | 485 => 306
  | 486 => 306
  | 487 => 307
  | 488 => 307
  | 489 => 308
  | 490 => 309
  | 491 => 309
  | 492 => 310
  | 493 => 311
  | 494 => 311
  | 495 => 312
  | 496 => 312
  | 497 => 313
  | 498 => 314
  | 499 => 314
  | 500 => 315
  | 501 => 316
  | 502 => 316
  | 503 => 317
  | 504 => 317
  | 505 => 318
  | 506 => 319
  | 507 => 319
  | 508 => 320
  | 509 => 321
  | 510 => 321
  | 511 => 322
  | 512 => 323
  | 513 => 323
  | 514 => 324
  | 515 => 324
  | 516 => 325
  | 517 => 326
  | 518 => 326
  | 519 => 327
  | 520 => 328
  | 521 => 328
  | 522 => 329
  | 523 => 329
  | 524 => 330
  | 525 => 331
  | 526 => 331
  | 527 => 332
  | 528 => 333
  | 529 => 333
  | 530 => 334
  | 531 => 335
  | 532 => 335
  | 533 => 336
  | 534 => 336
  | 535 => 337
  | 536 => 338
  | 537 => 338
  | 538 => 339
  | 539 => 340
  | 540 => 340
  | 541 => 341
  | 542 => 341
  | 543 => 342
  | 544 => 343
  | 545 => 343
  | 546 => 344
  | 547 => 345
  | 548 => 345
  | 549 => 346
  | 550 => 347
  | 551 => 347
  | 552 => 348
  | 553 => 348
  | 554 => 349
  | 555 => 350
  | 556 => 350
  | 557 => 351
  | 558 => 352
  | 559 => 352
  | 560 => 353
  | 561 => 353
  | 562 => 354
  | 563 => 355
  | 564 => 355
  | 565 => 356
  | 566 => 357
  | 567 => 357
  | 568 => 358
  | 569 => 358
  | 570 => 359
  | 571 => 360
  | 572 => 360
  | 573 => 361
  | 574 => 362
  | 575 => 362
  | 576 => 363
  | 577 => 364
  | 578 => 364
  | 579 => 365
  | 580 => 365
  | 581 => 366
  | 582 => 367
  | 583 => 367
  | 584 => 368
  | 585 => 369
  | 586 => 369
  | 587 => 370
  | 588 => 370
  | 589 => 371
  | 590 => 372
  | 591 => 372
  | 592 => 373
  | 593 => 374
  | 594 => 374
  | 595 => 375
  | 596 => 376
  | 597 => 376
  | 598 => 377
  | 599 => 377
  | 600 => 378
  | 601 => 379
  | 602 => 379
  | 603 => 380
  | 604 => 381
  | 605 => 381
  | 606 => 382
  | 607 => 382
  | 608 => 383
  | 609 => 384
  | 610 => 384
  | 611 => 385
  | 612 => 386
  | 613 => 386
  | 614 => 387
  | 615 => 388
  | 616 => 388
  | j => Nat.log 3 (2 ^ j - 1)

def qBound (j : Nat) : Odds :=
  BitVec.ofNat 10 (qBoundNat j)

structure TraceState where
  current : Value
  odds : Odds
  safe : Bool
  seenOne : Bool

def scan : Nat → Nat → Value → Value → Odds → Bool → Bool → TraceState
  | 0, _, _, current, odds, safe, seenOne =>
      { current, odds, safe, seenOne }
  | fuel + 1, j, start, current, odds, safe, seenOne =>
      let odd := isOdd current
      let noOverflow := !odd || current.ule maxSafeOddInput
      let next := accelerated current
      let odds' := odds + oddContribution odd
      let factorDecreases := odds'.ule (qBound (j + 1))
      let paradoxicalNow := factorDecreases && start.ule next
      scan fuel (j + 1) start next odds'
        (safe && noOverflow && !paradoxicalNow) (seenOne || next == 1)

def run (fuel : Nat) (input : Input) : TraceState :=
  let start := input.zeroExtend 64
  scan fuel 0 start start 0 true (start == 1)

def inClosedInterval (lo hi : Nat) (input : Input) : Bool :=
  (BitVec.ofNat 30 lo).ule input && input.ule (BitVec.ofNat 30 hi)

/-- No overflow and no paradoxical prefix among the first `fuel` steps. -/
def prefixSafe (fuel lo hi : Nat) (input : Input) : Bool :=
  !inClosedInterval lo hi input || (run fuel input).safe

/-- Prefix safety plus a visit to one during the bounded trace. -/
def completeTrace (fuel lo hi : Nat) (input : Input) : Bool :=
  !inClosedInterval lo hi input || ((run fuel input).safe && (run fuel input).seenOne)

/-!
The benchmark drivers use an explicit threshold list.  This keeps certificate
checking independent of reduction behavior for `Nat.log` or a large lookup
definition: element `j - 1` is the exact largest `q` satisfying `3^q < 2^j`.
-/

def scanBounds : List Odds → Value → Value → Odds → Bool → Bool → TraceState
  | [], _, current, odds, safe, seenOne =>
      { current, odds, safe, seenOne }
  | bound :: bounds, start, current, odds, safe, seenOne =>
      let odd := isOdd current
      let noOverflow := !odd || current.ule maxSafeOddInput
      let next := accelerated current
      let odds' := odds + oddContribution odd
      let factorDecreases := odds'.ule bound
      let paradoxicalNow := factorDecreases && start.ule next
      scanBounds bounds start next odds'
        (safe && noOverflow && !paradoxicalNow) (seenOne || next == 1)

def runBounds (bounds : List Odds) (input : Input) : TraceState :=
  let start := input.zeroExtend 64
  scanBounds bounds start start 0 true (start == 1)

def prefixSafeBounds (bounds : List Odds) (lo hi : Nat) (input : Input) : Bool :=
  !inClosedInterval lo hi input || (runBounds bounds input).safe

def completeTraceBounds (bounds : List Odds) (lo hi : Nat) (input : Input) : Bool :=
  !inClosedInterval lo hi input ||
    ((runBounds bounds input).safe && (runBounds bounds input).seenOne)

/-- A leaner trace for certifying one fixed segment length at a time. -/
structure RawState where
  current : Value
  odds : Odds
  noOverflow : Bool

def scanRaw : Nat → Value → Odds → Bool → RawState
  | 0, current, odds, noOverflow => { current, odds, noOverflow }
  | fuel + 1, current, odds, noOverflow =>
      let odd := isOdd current
      scanRaw fuel (accelerated current)
        (odds + oddContribution odd)
        (noOverflow && (!odd || current.ule maxSafeOddInput))

def runRaw (fuel : Nat) (input : Input) : RawState :=
  scanRaw fuel (input.zeroExtend 64) 0 true

/-- No overflow and no paradoxical segment at exactly `fuel` steps. -/
def safeAt (fuel : Nat) (bound : Odds) (lo hi : Nat) (input : Input) : Bool :=
  let start := input.zeroExtend 64
  let result := runRaw fuel input
  !inClosedInterval lo hi input ||
    (result.noOverflow && (!result.odds.ule bound || !start.ule result.current))

/-- Exact-length exclusion, conditional on the separately certifiable no-overflow invariant. -/
def noParadoxAt (fuel : Nat) (bound : Odds) (lo hi : Nat) (input : Input) : Bool :=
  let start := input.zeroExtend 64
  let result := runRaw fuel input
  !inClosedInterval lo hi input || !result.noOverflow ||
    !result.odds.ule bound || !start.ule result.current

/-- Exact-length/exact-odd-count exclusion after affine preprocessing. -/
def noParadoxAtExactOdds (fuel : Nat) (q : Odds) (lo hi : Nat) (input : Input) : Bool :=
  let start := input.zeroExtend 64
  let result := runRaw fuel input
  !inClosedInterval lo hi input || !result.noOverflow ||
    !(result.odds == q) || !start.ule result.current

/-- No 64-bit overflow along the first `fuel` accelerated steps. -/
def noOverflowThrough (fuel lo hi : Nat) (input : Input) : Bool :=
  !inClosedInterval lo hi input || (runRaw fuel input).noOverflow

/-!
Boolean ripple counter used to make exact odd-count constraints visible to the
BV reflector.  A `BitVec` sum containing conditional terms is abstracted by
the current frontend; these ten explicit Boolean gates are not.
-/

structure OddCounter where
  b0 : Bool := false
  b1 : Bool := false
  b2 : Bool := false
  b3 : Bool := false
  b4 : Bool := false
  b5 : Bool := false
  b6 : Bool := false
  b7 : Bool := false
  b8 : Bool := false
  b9 : Bool := false

def incrementCounter (carry : Bool) (x : OddCounter) : OddCounter :=
  let c1 := carry && x.b0
  let c2 := c1 && x.b1
  let c3 := c2 && x.b2
  let c4 := c3 && x.b3
  let c5 := c4 && x.b4
  let c6 := c5 && x.b5
  let c7 := c6 && x.b6
  let c8 := c7 && x.b7
  let c9 := c8 && x.b8
  { b0 := carry ^^ x.b0
    b1 := c1 ^^ x.b1
    b2 := c2 ^^ x.b2
    b3 := c3 ^^ x.b3
    b4 := c4 ^^ x.b4
    b5 := c5 ^^ x.b5
    b6 := c6 ^^ x.b6
    b7 := c7 ^^ x.b7
    b8 := c8 ^^ x.b8
    b9 := c9 ^^ x.b9 }

def counterEq (x y : OddCounter) : Bool :=
  (x.b0 == y.b0) && (x.b1 == y.b1) && (x.b2 == y.b2) &&
  (x.b3 == y.b3) && (x.b4 == y.b4) && (x.b5 == y.b5) &&
  (x.b6 == y.b6) && (x.b7 == y.b7) && (x.b8 == y.b8) &&
  (x.b9 == y.b9)

structure RawCounterState where
  current : Value
  odds : OddCounter
  noOverflow : Bool

def scanRawCounter : Nat → Value → OddCounter → Bool → RawCounterState
  | 0, current, odds, noOverflow => { current, odds, noOverflow }
  | fuel + 1, current, odds, noOverflow =>
      let odd := isOdd current
      scanRawCounter fuel (accelerated current) (incrementCounter odd odds)
        (noOverflow && (!odd || current.ule maxSafeOddInput))

def runRawCounter (fuel : Nat) (input : Input) : RawCounterState :=
  scanRawCounter fuel (input.zeroExtend 64) {} true

def noParadoxAtCounter (fuel : Nat) (q : OddCounter)
    (lo hi : Nat) (input : Input) : Bool :=
  let start := input.zeroExtend 64
  let result := runRawCounter fuel input
  !inClosedInterval lo hi input || !result.noOverflow ||
    !counterEq result.odds q || !start.ule result.current

/-!
Linear transition-chain encoding.  Intermediate states are independent SAT
variables constrained by exact one-step equations; this avoids expanding a
nested conditional trajectory before AIG common-subexpression sharing runs.
-/

def transition (current next : Value) : Bool :=
  (!isOdd current || current.ule maxSafeOddInput) && (next == accelerated current)

def chain : Value → List Value → Bool
  | _, [] => true
  | current, next :: rest => transition current next && chain next rest

def countChainInputs : Value → List Value → OddCounter
  | _, [] => {}
  | current, next :: rest =>
      incrementCounter (isOdd current) (countChainInputs next rest)

def chainEndpoint : Value → List Value → Value
  | current, [] => current
  | _, next :: rest => chainEndpoint next rest

def noParadoxChain (q : OddCounter) (lo hi : Nat)
    (input : Input) (states : List Value) : Bool :=
  let start := input.zeroExtend 64
  !inClosedInterval lo hi input || !chain start states ||
    !counterEq (countChainInputs start states) q ||
    !start.ule (chainEndpoint start states)

end BvCollatzBench

namespace BvCollatzBench.Tactic

open Lean Elab Tactic Meta
open Lean.Meta.Tactic.BVDecide
open Std.Sat
open Std.Tactic.BVDecide

private def instrumentedProver (cnfPath : System.FilePath) (ctx : TacticContext) :
    UnsatProver LratCert :=
  fun goal reflectionResult atomsAssignment => do
    let entry ← IO.lazyPure (fun _ => reflectionResult.bvExpr.bitblast)
    let aigNodes := entry.aig.decls.size
    let (cnf, _map) ← IO.lazyPure (fun _ =>
      let (entry, map) := entry.relabelNat'
      (AIG.toCNF entry, map))
    let dimacs ← IO.lazyPure (fun _ => cnf.dimacs)
    IO.FS.writeFile cnfPath dimacs
    logInfo m!"BV_BENCH aig_nodes={aigNodes} cnf_vars={cnf.numLiterals} cnf_clauses={cnf.clauses.size} cnf_path={cnfPath}"
    lratBitblaster ctx goal reflectionResult atomsAssignment

private def runBench (goal : MVarId) (cnfPath : System.FilePath) (ctx : TacticContext) :
    MetaM Unit := do
  let goal? ← Normalize.bvNormalize goal ctx.config
  let some goal := goal? | return
  match ← closeWithBVReflection goal (instrumentedProver cnfPath ctx) with
  | .ok _ => return
  | .error counterExample =>
      counterExample.goal.withContext do
        throwError (← addMessageContextFull (← explainCounterExampleQuality counterExample))

syntax (name := bvBench) "bv_bench " str : tactic

@[tactic bvBench]
def evalBvBench : Tactic := fun
  | `(tactic| bv_bench $path:str) => do
      let cnfPath : System.FilePath := path.getString
      let lratPath := cnfPath.withExtension "lrat"
      let config : Lean.Elab.Tactic.BVDecide.BVDecideConfig := {
        timeout := 3600
        trimProofs := false
        binaryProofs := true
        maxSteps := 10000000
      }
      let ctx ← TacticContext.new lratPath config
      liftMetaFinishingTactic fun goal => runBench goal cnfPath ctx
  | _ => throwUnsupportedSyntax

private def dumpGoal (goal : MVarId) (cnfPath : System.FilePath)
    (config : Lean.Elab.Tactic.BVDecide.BVDecideConfig) : MetaM Unit := do
  let goal? ← Normalize.bvNormalize goal config
  let some goal := goal? | return
  discard <| M.run do
    goal.withContext do
      let reflectionResult ← reflectBV goal
      let entry ← IO.lazyPure (fun _ => reflectionResult.bvExpr.bitblast)
      let (cnf, _map) ← IO.lazyPure (fun _ =>
        let (entry, map) := entry.relabelNat'
        (AIG.toCNF entry, map))
      IO.FS.writeFile cnfPath (← IO.lazyPure (fun _ => cnf.dimacs))
      logInfo m!"BV_DUMP aig_nodes={entry.aig.decls.size} cnf_vars={cnf.numLiterals} cnf_clauses={cnf.clauses.size} cnf_path={cnfPath}"

syntax (name := bvDump) "bv_dump " str : tactic

@[tactic bvDump]
def evalBvDump : Tactic := fun
  | `(tactic| bv_dump $path:str) => do
      let config : Lean.Elab.Tactic.BVDecide.BVDecideConfig := {
        maxSteps := 10000000
      }
      liftMetaTactic1 fun goal => do
        dumpGoal goal path.getString config
        return goal
  | _ => throwUnsupportedSyntax

end BvCollatzBench.Tactic
