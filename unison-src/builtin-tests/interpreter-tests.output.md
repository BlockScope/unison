
Note: This should be forked off of the codebase created by base.md

If you want to define more complex tests somewhere other than `tests.u`, just `load my-tests.u` then `add`,
then reference those tests (which should be of type `'{IO,Exception,Tests} ()`, written using calls
to `Tests.check` and `Tests.checkEqual`).

```ucm
.> run tests

  💔💥
  
  I've encountered a call to builtin.bug with the following
  value:
  
    ()
  
  
  Stack trace:
    bug
    shouldFail
    Tests.check
    Tests.run
    main
    #2upq759t0r

```



🛑

The transcript failed due to an error in the stanza above. The error is:


  💔💥
  
  I've encountered a call to builtin.bug with the following
  value:
  
    ()
  
  
  Stack trace:
    bug
    shouldFail
    Tests.check
    Tests.run
    main
    #2upq759t0r

