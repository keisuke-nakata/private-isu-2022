|dt|pass|score|success|fail|commit id|change log|
|--|--|--|--|--|--|--|
|20220703-155532|true|14006|13325|0|0415124597f5cc44d8c92aac0caad8e60dc377c3|comments add index post_id|
|20220703-160139|true|13726|13050|0|33a3cd6bf58b5a7dc55f676917ca219c90a4be00|test2|
|20220703-163523|true|14258|13551|0|4b689122ded5b3e8df1f2c67890ab9645b3a9837|add index comments (post_id, created_at DESC)|
|20220703-183319|true|14304|13610|0|1db17ad4ec1f33f4187dc21d090b73f899d12b4f|disable prepared statement|
|20220703-183734|true|15574|14775|0|be9bae9e4a1e4cdd4fe6cad4abc3cf74110a3897|disable prepared statement 2|
|20220703-205734|true|17216|16394|0|7454df760d00c6cd34f3dbe272687ad8ab755aea|mysql max_connection=256, go MaxOpenConns=0,MaxIdleConns=30|
|20220703-210536|true|17276|16453|0|c98169ab7404c9cab1c9ca4e006c8d9b20e0645e|disable_log_bin|
|20220703-211150|true|16637|15819|0|4a0cd41f59f4a239eef826b7b93e34f07d8d1cac|innodb_flush_log_at_trx_commit=0|
|20220703-211405|true|16637|15832|0|9d92bd9c610b9f2a54c32fc9ba1e73322c0a42fa|innodb_flush_log_at_trx_commit=0 take2|
|20220703-211756|true|17129|16287|0|3a88af0ee77ae48eaa318820db05f3cb1a51988b|revert to innodb_flush_log_at_trx_commit=1|
|20220703-214604|true|17128|16286|0|d2901437f105012d12a124837959af8349ef4f8b|serve css/js from nginx|
|20220703-214958|true|16789|16006|0|3ab4c5f801ee9c015b891aaf9b7be1effc769c27|static expires 1d|
|20220703-215735|true|17557|16745|0|f671ff3eae85ad1c5eef3f626583e3919c77839b|nginx gzip|
