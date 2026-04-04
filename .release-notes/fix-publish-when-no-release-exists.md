## Fix release note publishing when no GitHub Release exists

Release note publishing was broken for projects where the GitHub Release doesn't exist before the announcement stage. The `get_release` API call raises an exception on a missing release instead of returning a falsy value, so the fallback path that creates the release was never reached.
