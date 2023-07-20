use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn foo(c: &mut Criterion) {
    c.bench_function("foo", |b| {
        let init = 42;
        b.iter(|| black_box(init) * 42);
    });
}

criterion_group!(benches, foo);
criterion_main!(benches);
