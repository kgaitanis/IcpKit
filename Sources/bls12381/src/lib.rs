#[allow(clippy::all)]
#[allow(dead_code)]
mod bls;
use bls::bls12381::bls::{init, core_verify, BFS, BLS_OK};
use std::os::raw::{c_int, c_long};
use std::panic::{catch_unwind, UnwindSafe};
use std::sync::OnceLock;

// C ABI statuses: 1 = success, 0 = invalid input/verification failure,
// -1 = unexpected Rust panic. Never unwind across the C boundary.
fn ffi_status(operation: impl FnOnce() -> c_int + UnwindSafe) -> c_int {
    match catch_unwind(operation) {
        Ok(status) => status,
        Err(payload) => {
            // A custom panic payload could itself panic when dropped.
            std::mem::forget(payload);
            -1
        }
    }
}

#[no_mangle]
pub extern "C" fn bls_instantiate() -> c_int {
    static STATUS: OnceLock<c_int> = OnceLock::new();
    ffi_status(|| *STATUS.get_or_init(|| ffi_status(|| {
        if init() == BLS_OK { 1 } else { 0 }
    })))
}

// Nonempty pointers must reference readable allocations of the stated lengths
// for the duration of this call. Invalid pointers are not recoverable panics.
#[no_mangle]
pub extern "C" fn bls_verify(
    autograph_size: c_long, autograph_ptr: *const u8,
    message_size: c_long, message_ptr: *const u8,
    key_size: c_long, key_ptr: *const u8
) -> c_int {
    ffi_status(|| {
        if autograph_size != BFS as c_long || key_size != (2 * BFS) as c_long
            || message_size < 0 || message_size as u64 > isize::MAX as u64
            || autograph_ptr.is_null() || key_ptr.is_null()
            || (message_size > 0 && message_ptr.is_null()) {
            return 0;
        }
        let autograph = unsafe { std::slice::from_raw_parts(autograph_ptr, BFS) };
        let key = unsafe { std::slice::from_raw_parts(key_ptr, 2 * BFS) };
        // Swift may provide a null base address for an empty Data value.
        let message = if message_size == 0 {
            &[]
        } else {
            unsafe { std::slice::from_raw_parts(message_ptr, message_size as usize) }
        };
        if core_verify(autograph, message, key) == BLS_OK { 1 } else { 0 }
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn catches_unexpected_panics() {
        assert_eq!(ffi_status(|| panic!("unexpected verification failure")), -1);
        assert_eq!(ffi_status(|| 1), 1);
    }

    #[test]
    fn rejects_invalid_ffi_arguments() {
        let signature = [0x80; BFS];
        let key = [0x80; 2 * BFS];
        assert_eq!(bls_verify(-1, signature.as_ptr(), 0, std::ptr::null(),
                             key.len() as c_long, key.as_ptr()), 0);
        assert_eq!(bls_verify(BFS as c_long, std::ptr::null(), 0, std::ptr::null(),
                             key.len() as c_long, key.as_ptr()), 0);
        assert_eq!(bls_verify(BFS as c_long, signature.as_ptr(), 1, std::ptr::null(),
                             key.len() as c_long, key.as_ptr()), 0);
    }

    #[test]
    fn malformed_encodings_return_failure_without_panicking() {
        use crate::bls::bls12381::bls::BLS_FAIL;
        for length in [0, 1, BFS - 1, BFS, BFS + 1, 2 * BFS] {
            for byte in [0, 0x80, 0xc0, 0xff] {
                let signature = vec![byte; length];
                assert_eq!(core_verify(&signature, b"", &[0x80; 2 * BFS]), BLS_FAIL);
            }
        }
    }
}
