
import Lake
open Lake DSL

package spectralProof where
  leanOptions := #[⟨`timeout, 100000⟩]

lean_lib SpectralProof where
  roots := #[`Main]
