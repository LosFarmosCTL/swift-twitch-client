Keep README additions brief, you should not document everything inside of it, keep long-winded explanations
to the documentation - the README is supposed to be a quick landing page reference for the project.

Do not "over-test" the project, regression tests for complex behaviors where sensible are good - but avoid narrow
tests that are going to break with any code change anyways. For testing endpoints/subscriptions, keep the style
currently used in the project, do not introduce new tests for every single endpoint parameter or return value.
