const records = [
  { id: '1', title: 'Kind of Blue', artist: 'Miles Davis', year: 1959 },
  { id: '2', title: 'A Love Supreme', artist: 'John Coltrane', year: 1965 },
]

export const resolvers = {
  Query: {
    records: () => records,
  },
  Record: {
    __resolveReference: (ref: { id: string }) =>
      records.find((r) => r.id === ref.id),
  },
}
