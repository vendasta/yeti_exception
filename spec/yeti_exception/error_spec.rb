describe YetiException::Error do
  describe '#initialize' do
    let(:klass) { double('class') }
    let(:details) do
      {
        here: 'are',
        some: 'details'
      }
    end
    let(:transient) { double('transient') }
    let(:http_status) { double('http status') }

    subject { described_class.new(klass, details, transient, http_status) }

    it 'sets the attributes' do
      expect(subject.klass).to eq(klass)
      expect(subject.details).to eq(details)
      expect(subject.transient).to eq(transient)
      expect(subject.http_status).to eq(http_status)
    end

    it 'sets the message' do
      expected = details.map { |k, v| "#{k}=#{v.to_json}" }.join(' ')
      expect(subject.message).to eq(expected)
    end

    context 'when http status is omitted' do
      subject { described_class.new(klass, details, transient) }

      it 'sets the default http status' do
        expect(subject.http_status).to eq(500)
      end
    end

    context 'when transient and http status are omitted' do
      subject { described_class.new(klass, details) }

      it 'sets the defaults' do
        expect(subject.transient).to eq(true)
        expect(subject.http_status).to eq(500)
      end
    end

    context 'when message is defined' do
      let(:subklass) do
        Class.new(described_class) do
          def msg
            'BOOM!'
          end
        end
      end

      subject { subklass.new(klass, details) }

      it 'includes the message in the details' do
        expect(subject.details).
            to eq(details.merge(msg: 'BOOM!'))
      end

      context 'when the details also contain a message' do
        let(:details) do
          {
            here: 'are',
            some: 'details',
            msg: 'keep me'
          }
        end

        it 'keeps the value from the details' do
          expect(subject.details).to eq(details)
        end
      end
    end

  end
end
